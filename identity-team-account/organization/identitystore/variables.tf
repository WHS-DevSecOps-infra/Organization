variable "users" {
  description = "user information to be added to the identity store"
  type = map(object({
    display_name = string
    email        = string
    given_name   = string
    family_name  = string
  }))
}