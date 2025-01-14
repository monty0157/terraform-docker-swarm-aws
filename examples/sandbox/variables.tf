variable "daemon_count" {
  description = "This is the number of daemons to expose.  This is a workaround as count in some contexts cannot be a computed value."
  default     = 1
}

variable "ssh_key" {
  description = "SSH key to access the server."
}

variable "repo_url" {
  description = "URL to the proxy repo.  We are using Nexus so the URL is something like https://repo.trajano.net/repository/yum-group/.  Note trailing slash at the end."
  default     = ""
}

variable "repo_username" {
  description = "Username for the repo."
  default     = ""
}

variable "repo_password" {
  description = "Password for the repo."
  default     = ""
}

variable "managers" {
  description = "Number of managers in the swarm.  This should be an odd number otherwise there may be issues with raft consensus."
  default     = 3
}

variable "workers" {
  description = "Number of workers in the swarm."
  default     = 0
}

variable "instance_type" {
  description = "EC2 instance type."
  default     = "t3.micro"
}

