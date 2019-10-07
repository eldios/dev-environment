all: plan apply config

plan:
	export planFile="$$(date +%F).plan" && \
	terraform plan -out=$${planFile} -var-file=gcp.tfvars

apply:
	export planFile="$$(date +%F).plan" && \
	terraform apply $${planFile} 
	
config: 
	export planFile="$$(date +%F).plan" && \
	terraform output | tail +2 > ~/.ssh/meetup.conf

clean:
	terraform destroy -force -var-file=gcp.tfvars
