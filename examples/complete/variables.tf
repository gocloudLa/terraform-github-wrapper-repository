/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

# variable "metadata" {
#   type = any
# }

/*----------------------------------------------------------------------*/
/* Repository | Variable Definition                                     */
/*----------------------------------------------------------------------*/

variable "repository_parameters" {
  type        = any
  description = "Map of GitHub repositories to create (key is the repository name)."
  default     = {}
}

variable "repository_defaults" {
  type        = any
  description = "Default values merged into each entry of repository_parameters."
  default     = {}
}
