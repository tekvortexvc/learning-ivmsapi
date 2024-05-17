# iVMS API

iVMS API provides a RESTAPI endpoint that returns PunchClockParadox scores for all users in the system.


## Folder Structure
```
.
├── db                      # database schema and backup
├── Modules                 # Required PowerShell Modules
├── Dockerfile.app          # sample Dockerfile
├── ivmsapi.ps1             # PowerShell script to run API
├── env.sample              # sample env
└── README.md
```
## API Reference

#### Get all PCP Scores

```http
  GET /api/AverageAttDiff
```


## Deployment

### Requirements
- Database: SQL Server
- Platform: Powershell v5+
- PowerShell Modules: Polaris | SQLServer

### Windows
```cmd
  powershell ./ivmsapi.ps1
```

### Linux
```bash
  pwsh ./ivmsapi.ps1
```