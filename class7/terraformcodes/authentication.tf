resource "vault_auth_backend" "userpass" {
    type = "userpass"
}

resource "vault_generic_endpoint" "developers" {
    depends_on = [vault_auth_backend.userpass]

    
    path = "auth/userpass/users/developers"
    data_json = <<EOT
{
"policies" : ["admin", "developers"],
"password" : "lifeishell"
}
EOT
}