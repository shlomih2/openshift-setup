variable "audit_devices" {
  description = "A list of audit devices."
  type = list(object({
    type = string
    # local = bool
    options = map(any)
  }))
  default = []
}