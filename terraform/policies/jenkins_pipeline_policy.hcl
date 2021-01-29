#--> Read azure and auth/approle/role/webblog-approle/role-id path.
#--> Write secret-id with max_wrapping_ttl of 300s.
#--> Read KV: internal/data/tfc and internal/data/webblog/mongodb.

path "azure/*" {
  capabilities = [ "read" ]
}
path "auth/approle/role/webblog-approle/role-id" {
  policy = "read"
}
path "auth/approle/role/webblog-approle/secret-id" {
  policy = "write"
  min_wrapping_ttl   = "100s"
  max_wrapping_ttl   = "1000s"
}
path "internal/data/tfc" {
  capabilities = ["read"]
}
path "internal/data/webblog/mongodb" {
  capabilities = ["read"]
}
