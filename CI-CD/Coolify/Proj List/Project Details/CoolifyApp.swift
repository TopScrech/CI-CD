import Foundation

struct CoolifyApp: Identifiable, Decodable {
    var id: String {
        uuid
    }
    
    let uuid: String
    let environmentId: Int
    let repositoryProjectId: Int
    let name: String
    let description: String?
    let gitFullUrl: String?
    let fqdn: String?
    
    /// Helps to link apps to their parent proj
    var environmentName: String?
}

//[{"id": 0,"description": "string","repository_project_id": 0,"uuid": "string","name": "string","fqdn": "string","config_hash": "string","git_repository": "string","git_branch": "string","git_commit_sha": "string","git_full_url": "string","docker_registry_image_name": "string","docker_registry_image_tag": "string","build_pack": "string","static_image": "string","install_command": "string","build_command": "string","start_command": "string","ports_exposes": "string","ports_mappings": "string","custom_network_aliases": "string","base_directory": "string","publish_directory": "string","health_check_enabled": true,"health_check_path": "string","health_check_port": "string","health_check_host": "string","health_check_method": "string","health_check_return_code": 0,"health_check_scheme": "string","health_check_response_text": "string","health_check_interval": 0,"health_check_timeout": 0,"health_check_retries": 0,"health_check_start_period": 0,"limits_memory": "string","limits_memory_swap": "string","limits_memory_swappiness": 0,"limits_memory_reservation": "string","limits_cpus": "string","limits_cpuset": "string","limits_cpu_shares": 0,"status": "string","preview_url_template": "string","destination_type": "string","destination_id": 0,"source_id": 0,"private_key_id": 0,"environment_id": 0,"dockerfile": "string","dockerfile_location": "string","custom_labels": "string","dockerfile_target_build": "string","manual_webhook_secret_github": "string","manual_webhook_secret_gitlab": "string","manual_webhook_secret_bitbucket": "string","manual_webhook_secret_gitea": "string","docker_compose_location": "string","docker_compose": "string","docker_compose_raw": "string","docker_compose_domains": "string","docker_compose_custom_start_command": "string","docker_compose_custom_build_command": "string","swarm_replicas": 0,"swarm_placement_constraints": "string","custom_docker_run_options": "string","post_deployment_command": "string","post_deployment_command_container": "string","pre_deployment_command": "string","pre_deployment_command_container": "string","watch_paths": "string","custom_healthcheck_found": true,"redirect": "string","created_at": "string","updated_at": "string","deleted_at": "string","compose_parsing_version": "string","custom_nginx_configuration": "string","is_http_basic_auth_enabled": true,"http_basic_auth_username": "string","http_basic_auth_password": "string"}]
