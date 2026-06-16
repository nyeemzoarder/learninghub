#!/bin/bash

# Array of module directories and their concept files
declare -A modules=(
    ["00-prerequisites"]="01-cloud-computing-fundamentals 02-networking-basics 03-identity-and-access-fundamentals 04-azure-portal-navigation lab00-azure-portal-navigation"
    ["01-identity-governance"]="01-entra-id-overview 02-rbac-fundamentals 03-management-groups-and-azure-policy 04-access-control-scenarios 05-identity-best-practices lab01-entra-users-groups lab02-rbac-azure-policy lab03-management-groups-subscriptions"
    ["04-networking"]="01-vnets-and-subnets 02-network-security-groups 03-routing-fundamentals 04-vnet-peering 05-vpn-and-expressroute 06-hub-spoke-topology 07-private-endpoints-service-endpoints 08-network-security-advanced lab12-vnet-subnets lab13-nsg-asg lab14-vnet-peering-vpn lab15-load-balancer-app-gateway lab16-dns-name-resolution"
)

base_dir="/c/Users/nyeemzoarder/.claude/context/learning-hub"

for module in "${!modules[@]}"; do
    echo "Processing module: $module"
    docs_path="$base_dir/courses/az-104/$module/documents"
    
    # Read files in array
    files=(${modules[$module]})
    
    for file in "${files[@]}"; do
        filepath="$docs_path/$file.html"
        
        if [ -f "$filepath" ]; then
            echo "  Updating: $file.html"
            
            # For now just show which files exist
            # Actual updates will be done with Edit tool
        else
            echo "  File not found: $filepath"
        fi
    done
done
