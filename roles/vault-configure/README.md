# ==> cat out root keys for all three single-node clusters.

```shell
for i in {1..3}; do
cat /tmp/rootKey/hashi-a-${i}/rootKey; echo
done
```

Sample output.

```
s.2wFuEYlKM16LocQGAVPs4cZg
s.wkA7h2zcFk1B562vgTyR2ewS
s.wrrWIZLY2KbXPOyC2dJRa1XC
```

# ==> Configure Variables and Functions

```shell
export VAULT_PRIMARY_ADDR=http://hashi-a-1:8200
export VAULT_SECONDARY_ADDR=http://hashi-a-2:8200

export VAULT_PRIMARY_CLUSTER_ADDR=https://hashi-a-1:8201
export VAULT_SECONDARY_CLUSTER_ADDR=https://hashi-a-2:8201

vault_primary () {
  VAULT_ADDR=${VAULT_PRIMARY_ADDR} VAULT_TOKEN=$(cat /tmp/rootKey/hashi-a-1/rootKey) vault $@
}

vault_secondary () {
  VAULT_ADDR=${VAULT_SECONDARY_ADDR} VAULT_TOKEN=$(cat /tmp/rootKey/hashi-a-2/rootKey) vault $@
}
```

# ==> Logging
```
vault_primary audit enable file file_path=/var/log/vault-audit.log log_raw=true
vault_primary audit enable -path file-stdout file file_path=stdout log_raw=true
```

---
---
---

# ==> SETUP DR REPLICATION (Cluster A -> Cluster B)

## ==> 1. ENABLE DR REPLICATION ON PRIMARY CLUSTER (Cluster A)

```shell
echo "#--- Enable DR Replication on the primary"
vault_primary write -f sys/replication/dr/primary/enable

echo "#--- Create a DR secondary bootstrap token"
DR_TOKEN=$(vault_primary write -format=json \
    sys/replication/dr/primary/secondary-token \
    id="cluster-b" | jq -r '.wrap_info.token')
echo $DR_TOKEN
```

## ==> 2. ENABLE DR REPLICATION ON SECONDARY CLUSTER (Cluster B)

```shell
vault_secondary write sys/replication/dr/secondary/enable token=${DR_TOKEN}
```

Warning: This will immediately clear all data in the secondary cluster.

## ==> VERIFY

Check status from Primary DR cluster

```shell
echo "#==> Check status from Primary DR cluster with CLI"
vault_primary read sys/replication/dr/status
echo "#==> Check status from Secondary DR cluster with API"
curl -s $VAULT_SECONDARY_ADDR/v1/sys/replication/status | jq .data
```

Parameters to check on the primary:

- `cluster_id`: Unique ID for this set of replicas. This value must match on the Primary and Secondary.
- `known_secondaries`: List of the IDs of all non-revoked secondary activation tokens created by this Primary. The ID will be listed regardless of whether or not the token was used to activate an actual secondary cluster.
- `mode`: This should be "`primary`".
- `primary_cluster_addr`: If you set a `primary_cluster_addr` when enabling replication, it will appear here. If you did not explicitly set this, this field will be blank on the primary. As such, a blank field here can be completely normal.
- `state`: This value should be running on the primary. If the value is idle, it indicates an issue and needs to be investigated.'

On the Secondary:

- `cluster_id`: Unique ID for this set of replicas. This value must match on the Primary and Secondary.
  - `known_primary_cluster_addrs`: List of `cluster_addr` values from each of the nodes in the Primary's cluster. This list is updated approximately every 5 seconds and is used by the Secondary to know how to communicate with the Primary in the event of a Primary node's active leader changing.
- `last_remote_wal`: The last WAL index that the secondary received from the primary via WAL streaming.
  - `merkle_root`: A snapshot in time of the merkle tree's root hash. The merkle_root changes on every update to storage.
- `mode`: This should be '`secondary`'.
- `primary_cluster_addr`: This records the very first address that the secondary uses to communicate with the Primary after replication is enabled. It may not reflect the current address being used (see `known_primary_cluster_addrs`).
- `secondary_id`: The ID of the secondary activation token used to enable replication on this secondary cluster.
- `state`:
  - `stream-wals`: Indicates normal streaming. This is the value you want to see.
  - `merkle-diff`: Indicates that the cluster is determining the sync status to see if a merkle sync is required in order for the secondary to catch up to the primary.
  - `merkle-sync`: Indicates that the cluster is syncing. This happens when the secondary is too far behind the primary to use the normal stream-wals state for catching up. This state is blocking.
  - `idle`: Indicates an issue. You need to investigate.

---
---
---

# ==> FAILOVER TESTING - Demote Cluster A and Promote Cluster B

Time to test failover. First, we demote Cluster A. Then, we promote Cluster B.

## ==> DEMOTE PRIMARY CLUSTER

Demote Primary Cluster as Secondary Before Making DR CLuster Primary.

Always take care to never have two primary clusters running. You may lose data.

```shell
vault_primary write -f /sys/replication/dr/primary/demote
```

Check replication status on Cluster 1

```shell
echo "#--> Check replication status on Cluster 1"
vault_primary read -format=json sys/replication/dr/status | jq
```

`mode` should be secondary. `state` should be idle.

---

## ==> PROMOTE SECONDARY CLUSTER

### ==> GENERATE DR OPERATION TOKEN ON SECONDARY

To accomplish this you need a DR Operation Token on the DR Cluster
to perform any operations

NOTE: A DR cluster cannot accept any external transactions normally
Can verify by going to DR Secondary (vault3): http://hashi-a-2:8200

```
$ vault_primary secrets list
Error listing secrets engines: Error making API request.

URL: GET http://hashi-a-1:8200/v1/sys/mounts
Code: 400. Errors:

* path disabled in replication DR secondary mode
```

```shell
echo "#--- Validate process hasn't started yet on vault3"
curl -s $VAULT_SECONDARY_ADDR/v1/sys/replication/dr/secondary/generate-operation-token/attempt | jq

DR_OTP=$(vault_secondary operator generate-root -dr-token -generate-otp)
echo DR_OTP: $DR_OTP
NONCE=$(vault_secondary operator generate-root -dr-token -init -otp=${DR_OTP} | grep -i nonce | awk '{print $2}')
echo NONCE: $NONCE

for i in {1..3}; do
vault_secondary operator generate-root -dr-token \
  -nonce=$NONCE \
  $(cat /tmp/unsealKey/hashi-a-1/unseal_key_$i)
done | grep -i encoded | awk '{print $3}' | read ENCODED_TOKEN
echo ENCODED_TOKEN: $ENCODED_TOKEN
#ENCODED_TOKEN=$(vault operator generate-root -dr-token -nonce=${NONCE} ${PRIMARY_UNSEAL_KEY} | grep -i encoded | awk '{print $3}' )

DR_OPERATION_TOKEN=$(vault_secondary operator generate-root -dr-token -otp=${DR_OTP} -decode=${ENCODED_TOKEN})
echo "DR_OPERATION_TOKEN: $DR_OPERATION_TOKEN"
```

---

# ==> Promote vault.secondary DR Cluster to PRIMARY
```shell
vault_secondary write -f /sys/replication/dr/secondary/promote dr_operation_token="${DR_OPERATION_TOKEN}" primary_cluster_addr="${VAULT_SECONDARY_CLUSTER_ADDR}"
```

---

# Step 4: Generate a secondary activation token (Server B)
Generate a secondary activation token (Server B) so that you can activate Server A as its secondary:
https://www.vaultproject.io/api/system/replication-dr.html#generate-dr-secondary-token

```shell
echo "#==> From Cluster B - Generate a secondary activation token"
# The token has changed after replication setup.
vault_secondary () {
  VAULT_ADDR=${VAULT_SECONDARY_ADDR} VAULT_TOKEN=$(cat /tmp/rootKey/hashi-a-1/rootKey) vault $@
}

WRAPPING_TOKEN=$(vault_secondary write -format=json sys/replication/dr/primary/secondary-token id=cluster-a | jq -r '.wrap_info.token')
echo "WRAPPING_TOKEN: $WRAPPING_TOKEN"
```

## ==> VERIFY

```shell
vault_primary read sys/replication/dr/status
vault_secondary read sys/replication/dr/status
```

---

# Step 5: Generate a DR Operation Token (Server A)

```shell
echo "#--- Validate process hasn't started yet"
curl -s $VAULT_PRIMARY_ADDR/v1/sys/replication/dr/secondary/generate-operation-token/attempt | jq

DR_OTP=$(vault_primary operator generate-root -dr-token -generate-otp)
echo DR_OTP: $DR_OTP
NONCE=$(vault_primary operator generate-root -dr-token -init -otp=${DR_OTP} | grep -i nonce | awk '{print $2}')
echo NONCE: $NONCE
```

Run the following update call multiple times, using a different unseal (or recovery) key each time, until your unseal/recovery threshold is met and it returns an encoded DR Operation Token

```shell
for i in {1..3}; do
vault_primary operator generate-root -dr-token \
  -nonce=$NONCE \
  $(cat /tmp/unsealKey/hashi-a-1/unseal_key_$i)
done | grep -i encoded | awk '{print $3}' | read ENCODED_TOKEN
echo ENCODED_TOKEN: $ENCODED_TOKEN
#ENCODED_TOKEN=$(vault operator generate-root -dr-token -nonce=${NONCE} ${PRIMARY_UNSEAL_KEY} | grep -i encoded | awk '{print $3}' )
```

Then, decode the encoded DR operation token that is returned

```shell
DR_OPERATION_TOKEN=$(vault_primary operator generate-root -dr-token -otp=${DR_OTP} -decode=${ENCODED_TOKEN})
echo "DR_OPERATION_TOKEN: $DR_OPERATION_TOKEN"
```

```shell
vault_secondary () {
  VAULT_ADDR=${VAULT_SECONDARY_ADDR} VAULT_TOKEN=$(cat /tmp/rootKey/hashi-a-1/rootKey) vault $@
}
```

---

# Step 6: Update Server A to see Server B as its new primary

**Step 6**: Update Server A to see Server B as its new primary,  [using the update-primary endpoint](https://www.vaultproject.io/api/system/replication-dr.html#update-dr-secondary-39-s-primary) :

```shell
vault_primary write sys/replication/dr/secondary/update-primary \
  dr_operation_token=$DR_OPERATION_TOKEN token=$WRAPPING_TOKEN \
  primary_api_addr=http://hashi-a-2:8200
```

## ==> VERIFY

```shell
vault_primary read sys/replication/dr/status
vault_secondary read sys/replication/dr/status
```

---

# Trouble shooting

```shell
echo "#==> Revoke secondary token on primary"
vault_secondary write sys/replication/dr/primary/revoke-secondary id=new-secondary
echo "#==> Revoke dr operation token on secondary"
vault_primary delete /sys/replication/dr/secondary/generate-operation-token/attempt
```


# Random Notes
```
export VAULT_TOKEN=$(cat /tmp/rootKey/hashi-a-1/rootkey)
export VAULT_ADDR=http://hashi-a-1:8200
tf apply
```
