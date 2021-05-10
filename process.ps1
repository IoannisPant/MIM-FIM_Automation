# Written by Ioannis Pantelidis


#These paths need to be on FIM Server
Import-Module C:\Imports\FimSyncPowerShellModule.psm1
Import-Module C:\Imports\FimPowerShellModule.psm1
Import-Module C:\Imports\Get-FimSyncConfiguration.psm1


# Get all parameters in a structured way.
$Users = $PsBoundParameters.Values + $args 
#$Users = Import-csv C:\MIM_Automation\Users.csv

#Empty array for collection of the users that already exist.
$usersAlreadyExist = @()

#Function that checks if the user exist
Function CheckUserOnMIM {

	param (
        $userforcheck
	)
	
	#Do not show error if the user is not found.
	$ErrorActionPreference = "silentlycontinue"
	#Check on MIM If the user exist
	$check = Get-Resource -AttributeName "AccountName" -AttributeValue "$($userforcheck.AccountName)" -ObjectType Person 
	return $check
}


### Create the users in FIM 
foreach ($user in $Users)
{
	
	#retrieve the result from the function
	$checkedOnMIM = CheckUserOnMIM($user)
	
		#If user exists on MIM 
		If ($checkedOnMIM.count -ne 0) {
			
			#Save the users who already exist
			$usersAlreadyExist += $checkedOnMIM.Email 
			
		}else {	
									#Creation command for FIM
									New-FimImportObject -ObjectType Person -State Create -Changes @{
									DisplayName  = $user.DisplayName
									AccountName  = $user.AccountName
									FirstName    = $user.FirstName
									LastName     = $user.LastName
									Description  = 'Created by MIM Automation'
									EmployeeType = $user.EmployeeType
									OrganizationalUnit = $user.OrganizationalUnit
									Domain       = 'YourDomain'
									Email        = $user.email
									UPN        = $user.UPN
									O365_License	= "SI"
									LUP_CustomPortal = "CreateName"
									LUP_Password		= "defaultpassword"
									CF	=	$user.CF
									AlternateMail	=	$user.AlternateMail
									} -ApplyNow -ErrorAction SilentlyContinue
				
		}
	
	
}

if($usersAlreadyExist.count -gt 0){
	Write-Output "Users who already exist on MIM: "$usersAlreadyExist
}else{
	Write-Output "All MIM Users has been created successfully."
}


