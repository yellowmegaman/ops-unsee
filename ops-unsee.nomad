job "unsee" {
  datacenters = ["[[env "DC"]]"]
  type = "service"
  group "unsee" {
    count = "[[.unsee.count]]"
    restart {
      attempts = 5
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "unsee" {
      kill_timeout = "180s"
      env {
        PORT              = "[[.unsee.port]]"
	ALERTMANAGER_URI  = "[[.unsee.alertmanager.uri]]"
      }
      logs {
        max_files     = 5
        max_file_size = 10
      }
      driver = "docker"
      config {
        logging {
            type = "syslog"
            config {
              tag = "${NOMAD_JOB_NAME}${NOMAD_ALLOC_INDEX}"
            }   
        }
	network_mode       = "host"
        force_pull         = true
        image              = "cloudflare/unsee:[[.unsee.version]]"
        hostname           = "${attr.unique.hostname}"
	dns_servers        = ["${attr.unique.network.ip-address}"]
        dns_search_domains = ["consul","service.consul","node.consul"]
      }
      resources {
        memory             = "[[.unsee.ram]]"
        network {
          mbits            = 10
          port "healthcheck" { static = "[[.unsee.port]]" }
        } #network
      } #resources
      service {
        name = "unsee"
        tags = ["[[.unsee.version]]"]
        port = "healthcheck"
        check {
          name     = "unsee-internal-port-check"
          port     = "healthcheck"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        } #check
      } #service
    } #task
  } #group
} #job
