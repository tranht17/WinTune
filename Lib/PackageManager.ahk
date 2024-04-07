;================================================================================
; PackageManager
; tranht17
; 2024/04/07
;================================================================================

Class PackageManager {
	static __New() {
		DllCall('combase\RoActivateInstance'
			, 'Ptr', this.HString('Windows.Management.Deployment.PackageManager')
			, 'Ptr*', IPackageManager := ComValue(13, 0), 'HRESULT')
		this.IPackageManager:=IPackageManager
	}
	static IPackageManager2 {
		get => ComObjQuery(this.IPackageManager, "{F7AAD08D-0840-46F2-B5D8-CAD47693A095}")
	}
	static IPackageManager3 {
		get => ComObjQuery(this.IPackageManager, "{DAAD9948-36F1-41A7-9188-BC263E0DCB72}")
	}
	static IPackageManager8 {
		get => ComObjQuery(this.IPackageManager, "{B8575330-1298-4EE2-80EE-7F659C5D2782}")
	}
	static IPackageManager9 {
		get => ComObjQuery(this.IPackageManager, "{1AA79035-CC71-4B2E-80A6-C7041D8579A7}")
	}
	
	Class IPackage {
		__New(ptr?) {
            if IsSet(ptr) && !ptr
                throw ValueError('Invalid IUnknown interface pointer', -2, this.__Class)
            this.DefineProp("ptr", {Value:ptr ?? 0})
        }
        __Delete() => this.ptr ? ObjRelease(this.ptr) : 0
		
		IsFramework {
			get => (ComCall(8, this, "Char*", &value:=0), value)
		}
		Id {
			get => (ComCall(6, this, "Ptr*", IPackageId:=ComValue(13, 0)), IPackageId)
		}
		Name {
			get => (ComCall(6, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		Version {	
			get {
				PackageVersion := Buffer(8)
				ComCall(7, this.Id, 'Ptr', PackageVersion)
				Return Major:=NumGet(PackageVersion, "UShort") "." 
					. Minor:=NumGet(PackageVersion,2, "UShort") "."
					. Build:=NumGet(PackageVersion,4, "UShort") "."
					. Revision:=NumGet(PackageVersion,6, "UShort")
			}
		}
		Architecture {
			; 0: x86
			; 9: x64
			; 11: Neutral
			get => (ComCall(8, this.Id, "Int*", &value:=0), value)
		}
		Publisher {
			get => (ComCall(10, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		PublisherId {
			get => (ComCall(11, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		FullName {
			get => (ComCall(12, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		FamilyName {
			get => (ComCall(13, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		
		IPackage2 {
			get => ComObjQuery(this, "{A6612FB6-7688-4ACE-95FB-359538E7AA01}")
		}
		DisplayName {
			get => (ComCall(6, this.IPackage2, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		PublisherDisplayName {
			get => (ComCall(7, this.IPackage2, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		
		IPackage3 {
			get => ComObjQuery(this, "{5F738B61-F86A-4917-93D1-F1EE9D3B35D9}")
		}
		IPackageStatus {
			get => (ComCall(6, this.IPackage3, "Ptr*", value:=ComValue(13, 0)), value)
		}
		VerifyIsOK {
			get => (ComCall(6, this.IPackageStatus, "Char*", &value:=0), value)
		}
		NotAvailable {
			get => (ComCall(7, this.IPackageStatus, "Char*", &value:=0), value)
		}
		PackageOffline {
			get => (ComCall(8, this.IPackageStatus, "Char*", &value:=0), value)
		}
		DataOffline {
			get => (ComCall(9, this.IPackageStatus, "Char*", &value:=0), value)
		}
		Disabled {
			get => (ComCall(10, this.IPackageStatus, "Char*", &value:=0), value)
		}
		
		IPackage4 {
			get => ComObjQuery(this, "{65AED1AE-B95B-450C-882B-6255187F397E}")
		}
		SignatureKind {
			; PackageSignatureKind_None = 0,
			; PackageSignatureKind_Developer = 1,
			; PackageSignatureKind_Enterprise = 2,
			; PackageSignatureKind_Store = 3,
			; PackageSignatureKind_System = 4,
			get => (ComCall(6, this.IPackage4, "Int*", &value:=0), value)
		}
		
		IPackage5 {
			get => ComObjQuery(this, "{0E842DD4-D9AC-45ED-9A1E-74CE056B2635}")
		}
		
		UriLogo {
			get {
				ComCall(9, this.IPackage2, 'Ptr*', IUriRuntimeClass:=ComValue(13, 0)) ;get_Logo
				Return ComObjQuery(IUriRuntimeClass, "{9e365e57-48b2-4160-956f-c7385120bbfc}")
			}
		}
		DisplayUri {
			get => (ComCall(7, this.UriLogo, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		RawUri {
			get => (ComCall(16, this.UriLogo, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		Logo {
			get {
				InstalledPath:=this.InstalledPath
				Logo:=this.RawUri
				If !FileExist(Logo) {
					If !FileExist(Logo) {
						AppxManifest:=FileRead(InstalledPath "\AppxManifest.xml")
						If RegExMatch(AppxManifest, 'Square44x44Logo="(.*?)"', &SubPat) {
							Logo:= InstalledPath "\" SubPat[1]
							If !FileExist(Logo) {
								SplitPath Logo,, &dir, &ext, &name_no_ext
								Logo:=dir "\" name_no_ext ".scale-100." ext
							}
						}
					}
				}
				Return Logo
			}
		}
		
		IPackage8 {
			get => ComObjQuery(this, "{2C584F7B-CE2A-4BE6-A093-77CFBB2A7EA1}")
		}
		InstalledPath {
			get => (ComCall(9, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		MutablePath {
			get => (ComCall(10, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		EffectivePath {
			get => (ComCall(11, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		EffectiveExternalPath {
			get => (ComCall(12, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		MachineExternalPath {
			get => (ComCall(13, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
		UserExternalPath {
			get => (ComCall(14, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
		}
	}
	static RegisterPackage(manifestFilePath, dependencyPackageUris:=0, deploymentOptions:=0) {
		; deploymentOptions:
		; https://learn.microsoft.com/en-us/uwp/api/windows.management.deployment.deploymentoptions?view=winrt-22621
		ComCall(10, this.IPackageManager
			, 'Ptr', this.CreateUri(manifestFilePath)
			, 'Ptr', dependencyPackageUris
			, 'Ptr', deploymentOptions
			, 'Ptr*', DeploymentOperation := ComValue(13, 0))
		Return this.WaitForAsync(DeploymentOperation)
	}
	static RegisterPackageByFullName(mainPackageFullName, dependencyPackageFullNames:=0, deploymentOptions:=0) {
		ComCall(8, this.IPackageManager2
			, 'Ptr', this.HString(mainPackageFullName)
			, 'Ptr', dependencyPackageFullNames
			, 'Ptr', deploymentOptions
			, 'Ptr*', DeploymentOperation := ComValue(13, 0))
		Return this.WaitForAsync(DeploymentOperation)
	}
	static RemovePackage(packageFullName, removalOptions:=0) {
		If removalOptions {
			; RemovalOptions_None = 0,
			; RemovalOptions_PreserveApplicationData = 0x1000,
			; RemovalOptions_PreserveRoamableApplicationData = 0x80,
			; RemovalOptions_RemoveForAllUsers = 0x80000
			ComCall(6, this.IPackageManager2
				, 'Ptr', this.HString(packageFullName)
				, 'UInt', removalOptions
				, 'Ptr*', DeploymentOperation := ComValue(13, 0)) ;RemovePackageWithOptionsAsync
		} Else {
			ComCall(8, this.IPackageManager
				, 'Ptr', this.HString(packageFullName)
				, 'Ptr*', DeploymentOperation := ComValue(13, 0)) ;RemovePackageAsync
		}
		Return this.WaitForAsync(DeploymentOperation)
		; 0x80073D19 : An error occurred because a user was logged off.
		; 0x8a15000f : Data required by the source is missing. No packages were found among the working sources.
		; 0x80073cfa
	}
	static FindPackages(UserSID:="", IncludeFramework:=0, IncludeSignatureKindSystem:=0) {
		; UserSID="": Current UserSID
		If UserSID="All"
			ComCall(11, this.IPackageManager, 'Ptr*', PackageCollection := ComValue(13, 0)) ;FindPackages
		Else
			ComCall(12, this.IPackageManager
				, 'Ptr', (UserSID?this.HString(UserSID):0)
				, 'Ptr*', PackageCollection := ComValue(13, 0)) ;FindPackagesByUserSecurityId
		ComCall(6, PackageCollection, 'Ptr*', CPackage:=ComValue(13, 0)) ;First
		arr := Array()
		Loop {
			obj:={}
			ComCall(6, CPackage, 'Ptr*', IPackage:=this.IPackage()) ;get_Current
			SignatureKind:=IPackage.SignatureKind
			IsFramework:=IPackage.IsFramework
			FamilyName:=IPackage.FamilyName
			If (IncludeSignatureKindSystem 
					|| (!IncludeSignatureKindSystem 
						&& SignatureKind!=4 
						&& FamilyName != "Microsoft.SecHealthUI_8wekyb3d8bbwe" 
						&& FamilyName!="Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"))
				&& (IncludeFramework
					|| (!IncludeFramework && IsFramework==0)) {
				arr.Push IPackage
			}
			ComCall(8, CPackage, 'Char*', &IsMoveNext:=0) ;MoveNext
			If !IsMoveNext {
				IPackage:=""
				CPackage:=""
				PackageCollection:=""
				Break
			}
		}
		return arr
	}
	static FindPackagesByPackageFamilyName(packageFamilyName, UserSID:="") {
		If UserSID && UserSID="All"
			ComCall(19, this.IPackageManager
				, 'Ptr', this.HString(packageFamilyName)
				, 'Ptr*', PackageCollection := ComValue(13, 0)) ;FindPackagesByPackageFamilyName
		Else
			ComCall(20, this.IPackageManager
				, 'Ptr', (UserSID?this.HString(UserSID):0)
				, 'Ptr', this.HString(packageFamilyName)
				, 'Ptr*', PackageCollection := ComValue(13, 0)) ;FindPackagesByUserSecurityIdPackageFamilyName
		ComCall(6, PackageCollection, 'Ptr*', CPackage:=ComValue(13, 0)) ;First
		arr := Array()
		Loop {
			ComCall(6, CPackage, 'Ptr*', IPackage:=this.IPackage()) ;get_Current
			arr.Push IPackage
			ComCall(8, CPackage, 'Char*', &IsMoveNext:=0) ;MoveNext
			If !IsMoveNext {
				IPackage:=""
				CPackage:=""
				PackageCollection:=""
				Break
			}
		}
		return arr
	}
	
	; Windows 10, version 2004 (introduced in 10.0.19041.0)
	static FindProvisionedPackages() {
		arr := Array()
		ComCall(6, this.IPackageManager9, 'Ptr*', PackageCollection := ComValue(13, 0))
		ComCall(7, PackageCollection, 'UInt*', &Size:=0) ;get_Size
		Loop Size {
			ComCall(6, PackageCollection, "UInt", A_Index-1, 'Ptr*', IPackage := this.IPackage()) ;GetAt
			arr.Push IPackage
		}
		IPackage:=""
		PackageCollection:=""
		return arr
	}
	; Windows 10, version 1809 (introduced in 10.0.17763.0)
	static DeprovisionPackageForAllUsers(packageFamilyName) {
		ComCall(6, this.IPackageManager8
			, 'Ptr', this.HString(packageFamilyName)
			, 'Ptr*', DeploymentOperation := ComValue(13, 0))
		Return this.WaitForAsync(DeploymentOperation)
	}
	
	static SetPackageStatus(packageFullName, PackageStatus:=0) {
		; PackageStatus_OK := 0
		; PackageStatus_LicenseIssue := 0x1
		; PackageStatus_Modified := 0x2
		; PackageStatus_Tampered := 0x4
		; PackageStatus_Disabled := 0x8
		; PackageStatus:= This enumeration supports a bitwise combination of its member values.
		ComCall(16, this.IPackageManager3, 'Ptr', this.HString(packageFullName), 'UInt', PackageStatus)
	}
	static ClearPackageStatus(packageFullName, PackageStatus:=0) {
		ComCall(8, this.IPackageManager3, 'Ptr', this.HString(packageFullName), 'UInt', PackageStatus)
	}
	
	static CheckInstallUser(packageFullName, UserSID_Need_Search, InstallState:=2) {
		ComCall(15, this.IPackageManager, 'Ptr', this.HString(packageFullName), 'Ptr*', Iterable_Users := ComValue(13, 0)) ;FindUsers
		ComCall(6, Iterable_Users, 'Ptr*', Iterator_User:=ComValue(13, 0)) ;First
		s:=0
		Loop {
			ComCall(7, Iterator_User, 'Char*', &HasCurrent:=0) ;get_HasCurrent
			If !HasCurrent
				Break
			ComCall(6, Iterator_User, 'Ptr*', ABI_User:=ComValue(13, 0)) ;get_Current
			ComCall(6, ABI_User, 'Ptr*', &UserSecurityId:=0) ;get_UserSecurityId
			ComCall(7, ABI_User, 'UInt*', &PackageInstallState:=0) ;get_InstallState
			; PackageInstallState_NotInstalled = 0 ;The package has not been installed.
			; PackageInstallState_Staged = 1 ;The package has been downloaded.
			; PackageInstallState_Installed = 2 ;The package is ready for use.
			; PackageInstallState_Paused = 6 ;The installation of the package has been paused.

			If this.HStringToStr(UserSecurityId)=UserSID_Need_Search && PackageInstallState==InstallState {
				s:=1
				Break
			}
			ComCall(8, Iterator_User, 'Char*', &IsMoveNext:=0) ;MoveNext
			If !IsMoveNext
				Break
		}
		ABI_User:=""
		UserSecurityId:=""
		Iterator_User:=""
		Iterable_Users:=""
		Return s
	}
	
	static WaitForAsync(obj, rIndex:=0, rType:="Ptr*", &rArg:=ComValue(13, 0)) {
		local AsyncInfo := ComObjQuery(obj, "{00000036-0000-0000-C000-000000000046}"), status, ErrorCode
		Loop {
			ComCall(7, AsyncInfo, "uint*", &status:=0)
			; AsyncStatus
			  ; 0:Started:  The operation is in progress.
			  ; 1:Completed:The operation has completed without error.
			  ; 2:Canceled: The client has initiated a cancellation of the operation.
			  ; 3:Error:    The operation has completed with an error. No results are available.
			if (status != 0) {
				if (status = 3) {
					ComCall(8, ASyncInfo, "uint*", &ErrorCode:=0)
					A_LastError:=ErrorCode
				}
				break
			}
		  Sleep 10
		}
		If rIndex!=0 {
			ComCall(rIndex, obj, rType, rArg) ;GetResults
		}
		ComCall(10, AsyncInfo)
		Return status
	}
	
	static CreateUri(str) {
		result := DllCall("Combase\RoGetActivationFactory"
				, "Ptr", this.HString("Windows.Foundation.Uri")
				, "Ptr", this.CLSIDFromString("{44A9796F-723E-4FDF-A218-033E75B0C084}")
				, "Ptr*", IUriRuntimeClassFactory:=ComValue(13, 0), "HRESULT")
		ComCall(6, IUriRuntimeClassFactory, "Ptr", this.HString(str), "Ptr*", IUriRuntimeClass2:=ComValue(13, 0))
		Return IUriRuntimeClass2
	}

	class HString {
		Ptr:=0
		__New(str) => DllCall('combase\WindowsCreateString', 'WStr', str, 'UInt', StrLen(str), 'Ptr*', this, 'HRESULT')
		__Delete() => DllCall('combase\WindowsDeleteString', 'Ptr', this, 'HRESULT')
	}

	static HStringToStr(HS) {
		bStr:=DllCall("Combase.dll\WindowsGetStringRawBuffer", "Ptr", HS, "uint*", &length:=0, "Ptr")
		Return StrGet(bStr)
	}
	static CLSIDFromString(IID) {
		local CLSID := Buffer(16), res
		if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", CLSID, "UInt")
		   throw Error("CLSIDFromString failed. Error: " . Format("{:#x}", res))
		Return CLSID
	}
}

PS_RemovePackage(packageFullName, UserSID:="", removalOptions:="") {
	; -PreserveApplicationData: 
		; Specifies that the cmdlet preserves the application data during the package removal. 
		; The application data is available for later use.
		; Note that this is only applicable for apps that are under development 
		; so this option can only be specified for apps that are registered from file layout (Loose file registered).
	; -PreserveRoamableApplicationData:
		; Preserves the roamable portion of the app's data when the package is removed.
		; This parameter is incompatible with PreserveApplicationData.
	UserParam:=""
	If UserSID="All"
		UserParam:=" -AllUsers"
	Else If UserSID
		UserParam:=" -User " UserSID
	UserParam.=removalOptions?" " removalOptions:""
	Return RunTerminal('Powershell Remove-AppxPackage -Package ' packageFullName UserParam)
}