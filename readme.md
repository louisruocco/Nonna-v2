# Nonna v2: 

The newer, more improved version of the original Nonna v1 Repo!

## Changelog:

### v2.0:
- Have moved everything over into Azure now
    - This app started as a Virtual Machine and local scripts running off it (See Nonna v1 repo)
    - With v2.0, Nonna has now become a runbook that pulls data from an Azure Blob container and secrets from a Key Vault
- **Added Youtube API back into script**
    - This was a feature present in Nonna-v1. It
    - This feature uses the Youtube API to find the first 5 youtube videos based on what is the current Learning Topic in 'other learning.txt'

### v1.0:
- Initial Commit
- Nonna now working out of an Azure runbook
    - Youtube API to be integrated shortly
    - viper VM to be decommissioned in a couple of days