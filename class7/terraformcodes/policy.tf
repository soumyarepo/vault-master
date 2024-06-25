resource "vault_policy" "admin" {
    name = "admin"
    policy = <<EOT
path "kv-v2/*" {
    capabilities = ["create", "update", "delete", "read", "list"]
}
path "transit/*" {
    capabilities = ["create", "update", "delete", "read", "list"]
}

path "auth/userpass/*" {
    capabilities = ["create", "update", "delete", "read", "list"]
}
EOT
}

resource "vault_policy" "developers" {
    name = "developers"
    policy = <<EOT
path "kv-v2/data/*" {
    capabilities = ["read", "list"]
}
path "transit/keys/dummytransit" {
    capabilities = ["read", "update"]
}
EOT
}