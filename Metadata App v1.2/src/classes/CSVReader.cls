public class CSVReader  {
    
    public string nameFile{get;set;}
    public String check{get;set;}
    public Blob contentFile{get;set;}
    private List<DataStructure> dsList=new LIST<DataStructure>();
    public  String dataType{get;set;}
    public  LIST<SelectOption> dataTypeList=new LIST<SelectOption>();
    public Boolean isCreateFieldCalled=false;
    Set<String> profileSet=new Set<String>();
    public static Boolean checkboxStateForReadonly{get;set;}
    public static Boolean checkboxStateForVisible{get;set;}
    List<SelectOption> dataTypeOptions=new LIST<SelectOption>();
    List<SelectOption> allSobjects = new List<SelectOption>();
    Boolean isgetdataTypeOptions=false;
    public static Boolean isObjectNameEditable{get;set;}
    private List<DataStructure> successList = new List<DataStructure>();
    private List<DataStructure> errorList = new List<DataStructure>();
    public Boolean isRenderErrorResult{get;set;}
    public Boolean showDownloadFilesButton{get;set;}
    public Boolean isCancelCalled=false;
    public Boolean validationCompleteLabel{get;set;}
    public Boolean disableSubmitAndCancelBtnOnReviewPage{get;set;}
    public Boolean hideSubmitSection{get;set;}
    public Integer successListSize{get;set;}
    public Integer errorListSize{get;set;}
    public Boolean showErrorColumns{get;set;}
    public Boolean hideExtraColumnsAfterFinalSubmit{get;set;}    
    public Boolean showApplyToAllPopUp{get;set;}
    public List<selectoption> allPofileReadOnlylist{get;set;}
    public List<selectoption> allPofileVisibleList{get;set;}
    public List<selectoption> selectedReadOnlyList{get;set;}
    public List<selectoption> selectedVisibleList{get;set;}
    /*****************************************************************************************************************************************************/   
    //Read CSV File and Create Datastructure
    public Pagereference ReadFile()
    {   
        
        try
        {
            System.debug('Called ReadFile');
            PageReference secondPage = new PageReference('/apex/MetadataDemoPageNEW');
            nameFile=contentFile.toString();                //ContentFile Contains Data in BLOB Format
            String[] inputValues=nameFile.split('\n');      //Spliting Each Row of CSV File
            system.debug('@@@@@@ security check 1');
            createDataStructure(inputValues);
            system.debug('@@@@@@ security check 2');
            isCancelCalled=false;
            createStructureForFLS(this.dsList);
            system.debug('@@@@@@ security check 3');
            createStructureForLayoutAssignment(this.dsList);
            system.debug('@@@@@@ security check 4');
            isRenderErrorResult=false;
            system.debug('@@@@@@ security check 5');
            
            // initialization
            selectedVisibleList = new List<selectOption>();
            selectedReadOnlyList = new List<selectOption>();
            return secondPage;
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a file to upload')); 
            return null;
        }
    }
    /*****************************************************************************************************************************************************/       
    //On Submit button Action pass date to MetadataApi Class to create Fields, Apply FLS, and add to PageLayout
    public PageReference createField()
    {
        System.debug('Called CreateField');
        System.debug('Inside createField');
        isCreateFieldCalled=true;
        isObjectNameEditable=true;
        showDownloadFilesButton=true;
        MetadataApi.createField(dsList);
        MetadataApi.updateFieldLevelSecurity(dsList);
        MetadataApi.addFieldToLayout(dsList);
        return null;
    }
    
    /*****************************************************************************************************************************************************/   
    public void createDataStructure(String[] inputvalues)
    {
        System.debug('Inside createDataStructure');
        for(Integer i=1;i<inputValues.size();i++)
        {
            String[] inputvalue=inputValues[i].split(',');      //Spliting Each Coloumn of CSV data
            if(inputvalue[0]!='' && inputvalue[1]!='' && inputvalue[2]!='')   
            {
                System.debug(''+inputvalue);
                System.debug(''+inputvalue[8]);
                DataStructure ds=new DataStructure();
                system.debug('@@ inside check  point 1');
                ds.objectName=inputvalue[0].trim();
                ds.fieldType=inputvalue[1].trim();
                ds.changedDataType=ds.fieldType;
                ds.fieldLabel=inputvalue[2].trim();
                
                //******Field Name must be removed from CSV ---Himani
                if(ds.fieldLabel!=null)
                {
                    getCorrectFieldName(ds, inputvalue);
                } 
                
                //if Data Type contains Length Field
                if(ds.dataTypeContainsLengthField.contains(ds.fieldType))
                {
                    if(inputvalue[4].trim()!=null && inputvalue[4].trim()!='')
                        ds.length=inputvalue[4].trim();
                    else
                        ds.length='0';
                }
                
                //if Data Type contains Decimal Field
                if(ds.dataTypeContainsDecimalPlaceField.contains(ds.fieldType))
                {
                    if(inputvalue[5].trim()!=null && inputvalue[5].trim()!='')
                        ds.decimalPlace=(inputvalue[5].trim());
                    else
                        ds.decimalPlace='0';    
                }
                
                //if Data Type contains Visible Lines Field
                if(ds.dataTypeContainsVisibleLinesField.contains(ds.fieldType))
                {
                    if(inputvalue[6].trim()!=null && inputvalue[6].trim()!='')
                        ds.visibleLines=(inputvalue[6].trim());
                    else
                        ds.visibleLines='0';
                }
                
                //if Data Type is Picklist or MultiselectPicklist
                if(ds.fieldType=='Picklist'||ds.fieldType=='MultiselectPicklist')
                {
                    if(inputvalue[7].trim()!=null && inputvalue[7].trim()!='')
                    {
                        List<String> pickValList=inputvalue[7].split(';');
                        ds.picklistValues=new List<String>();
                        ds.picklistValues.addAll(pickValList);
                        ds.picklistValue = '';
                        for(String str : pickValList) {
                            ds.picklistValue = ds.picklistValue +str + '\n';
                        }
                    }
                    else
                        ds.picklistValue='';
                    
                    if(inputvalue[8].trim()!=null && inputvalue[8].trim()!='')
                        ds.picklistSorted=Boolean.valueOf(inputvalue[8].trim());
                    
                    ds.picklistSortedCheck='';
                }
                if(ds.dataTypeContainsDefaultField.contains(ds.fieldType))
                {
                    if(inputvalue[9].trim()!=null && inputvalue[9].trim()!='')
                        ds.fieldDefaultValue=inputvalue[9].trim();
                    if(ds.fieldType=='Checkbox')
                        ds.fieldDefaultValue=String.valueOf(false);
                    else
                        ds.fieldDefaultValue='';                
                }            
                if(ds.dataTypeContainsRequiredField.contains(ds.fieldType))
                {
                    if(inputvalue[10].trim()!=null && inputvalue[10].trim()!='')
                        ds.required=Boolean.valueOf(inputvalue[10].trim());
                    
                    ds.requiredCheck='';
                }
                
                if(inputvalue[11].trim()!=null && inputvalue[11].trim()!='')
                    ds.trackFeedHistory=Boolean.valueOf(inputvalue[11].trim());
                
                if(ds.dataTypeContainsUniqueField.contains(ds.fieldType))
                {
                    if(inputvalue[12].trim()!=null && inputvalue[12].trim()!='')
                        ds.unique=Boolean.valueOf(inputvalue[12].trim());
                    
                    ds.uniqueCheck='';
                }
                
                if(ds.dataTypeContainsExternalIDField.contains(ds.fieldType))
                {
                    if(inputvalue[13].trim()!=null && inputvalue[13].trim()!='')
                        ds.externalId=Boolean.valueOf(inputvalue[13].trim());
                    
                    ds.externalIdCheck='';
                }
                if(ds.fieldType=='Lookup')
                {
                    if(inputValue[14].trim()!=null && inputvalue[14].trim()!='')
                    {
                        ds.relatedToObject=inputValue[14].trim();
                    }
                    
                    if(inputValue[15].trim()!=null && inputvalue[15].trim()!='')
                    {
                        ds.childRelationshipName=inputValue[15].trim();                
                    }
                    
                    if(inputValue[16].trim()!=null && inputvalue[16].trim()!='')
                    {
                        ds.relatedListLabel=inputValue[16].trim();
                    }
                    ds.lookupFieldCheck='';
                    
                } 
                
                if(inputvalue[17].trim()!=null && inputvalue[17].trim()!='')
                    ds.Description=inputvalue[17].trim();
                if(inputvalue[18].trim()!=null && inputvalue[18].trim()!='')
                    ds.helpText=inputvalue[18].trim();
                
                ds.selectedOptionsForLayoutAssignment=new List<SelectOption>();
                ds.selectedOptionsForReadOnly=new List<SelectOption>();
                ds.selectedOptionsForVisibleOnly=new List<SelectOption>();
                dsList.add(ds);
            }
        }
    }
    
    /*****************************************************************************************************************************************************/    
    private void getCorrectFieldName(DataStructure ds, String[] inputvalue)
    {
        ds.fieldName=inputvalue[2].replaceAll('\\s+', ' ').trim().replaceAll('[\\W]', '_');//+'__c';
        
        String firstCharacter=ds.fieldName.substring(0,1);
        if(firstCharacter.isNumeric())
        {
            ds.fieldName='X' + ds.fieldName;
        }
        ds.fieldName=ds.fieldName.replaceAll('\\_+', '_');
        Integer fieldNameLength=ds.fieldName.length();
        String lastCharacter=ds.fieldName.substring(fieldNameLength-1, fieldNameLength);
        ds.fieldName=ds.fieldName+'__c';
        if(lastCharacter=='_')
        {
            ds.fieldName=ds.fieldName.replaceAll('__','_');
        }
    }
    
    
    /*****************************************************************************************************************************************************/       
    
    public  List<SelectOption> getdataTypeOptions() 
    {
        if(!isgetdataTypeOptions)
        {
            dataTypeOptions = UtilityClass.getAllFieldType();
            isgetdataTypeOptions=true;
        }
        return dataTypeOptions;
    }
    
    /*****************************************************************************************************************************************************/       
    public void createStructureForFLS(List<DataStructure> dsList)
    {
        profileSet=MetadataApi.fetchAllProfile();
        if(profileSet.size()> 0 && !profileSet.isEmpty())
        {
            for(DataStructure ds: dsList)
            {
                ds.allOptionsForReadOnly=new List<SelectOption>();
                ds.allOptionsForVisibleOnly=new List<SelectOption>();
                allPofileVisibleList=new List<SelectOption>();
                allPofileReadOnlylist=new List<SelectOption>(); 
                for(String str:profileSet)
                {
                    String displayProfileName;
                    if(str.contains('%2E'))
                        displayProfileName=str.replaceAll('%2E','.');
                    
                    else if(str.contains('%3A'))
                        displayProfileName=str.replaceAll('%3A',':');
                    else
                        displayProfileName=str;
                    ds.allOptionsForReadOnly.add(new SelectOption(str,displayProfileName));
                    ds.allOptionsForVisibleOnly.add(new SelectOption(str,displayProfileName));
                    allPofileVisibleList.add(new SelectOption(str,displayProfileName));
                    allPofileReadOnlylist.add(new SelectOption(str,displayProfileName));
                }
            }
        }    
    }
    
    /*****************************************************************************************************************************************************/       
    public void createStructureForLayoutAssignment(List<DataStructure> dsList)
    {
        Map<String, List<String>> objectLayoutMap=new  Map<String, List<String>>();
        objectLayoutMap=MetadataApi.fetchAllLayouts();
        for(DataStructure ds:dsList)
        {
            ds.allOptionsForLayoutAssignment = new List<SelectOption>();
            Set<String> tempSetOfselectedOptionsForLayoutAssignment=new Set<String>();
            
            if(ds.selectedOptionsForLayoutAssignment!=null && ds.selectedOptionsForLayoutAssignment.size()>0)
            {
                for(SelectOption so:ds.selectedOptionsForLayoutAssignment)
                    tempSetOfselectedOptionsForLayoutAssignment.add(so.getValue());
            }
            if(objectLayoutMap.containsKey(ds.objectName))
            {
                for(String str:(objectLayoutMap.get(ds.objectName)))
                {
                    String displayLayou=str.replaceAll('%28','(');
                    displayLayou=displayLayou.replaceAll('%29',')');
                    if(!tempSetOfselectedOptionsForLayoutAssignment.contains(str))
                        ds.allOptionsForLayoutAssignment.add(new SelectOption(str,displayLayou));       
                }
            }
        }
    }
    
    /*****************************************************************************************************************************************************/       
    
    public void changeStructure()
    {
        createStructureForLayoutAssignment(this.dsList);
        for(DataStructure ds: dsList)
        {
            System.debug('ds.fieldType'+ds.fieldType +'*********'+'ds.changedDataType'+ds.changedDataType);
            if(ds.fieldType != ds.changedDataType)
            {
                ds.fieldType = ds.changedDataType;
                UtilityClass.changeStructure(ds);
            }
        }
    }
    
    /*****************************************************************************************************************************************************/           
    public PageReference initialState()
    {
        for(DataStructure ds:dsList)
        {
            if(ds.isUpdatable)
            {
                if(ds.changedDataType != ds.fieldType)
                {
                    ds.changedDataType=ds.fieldType;
                }
            }
        }
        return null;
    }
    
    /*****************************************************************************************************************************************************/       
    public void applyReadonlyToAllProfiles()
    { 
        List<SelectOption> listFirstSelectedProfile=new List<SelectOption>();
        listFirstSelectedProfile=dsList[0].selectedOptionsForReadOnly;
        for(Integer i = 1; i < dsList.size(); i++)
        {
            DataStructure ds = dsList.get(i);
            ds.selectedOptionsForReadOnly.clear();
            ds.selectedOptionsForReadOnly.addAll(listFirstSelectedProfile);
        }
        
    }
    
    /*****************************************************************************************************************************************************/        
    public void applyVisibleToAllProfiles()
    {
        List<SelectOption> listFirstSelectedProfile=new List<SelectOption>();
        listFirstSelectedProfile=dsList[0].selectedOptionsForVisibleOnly;
        for(Integer i = 1; i < dsList.size(); i++)
        {
            DataStructure ds = dsList.get(i);
            ds.selectedOptionsForVisibleOnly.clear();
            ds.selectedOptionsForVisibleOnly.addAll(listFirstSelectedProfile);
        }  
    }
    
    /*****************************************************************************************************************************************************/            
    public PageReference addNewRowInTable()
    {
        Map<String, List<String>> objectLayoutMap=new  Map<String, List<String>>();
        DataStructure ds=new DataStructure();
        ds.selectedOptionsForLayoutAssignment = new List<Selectoption>();
        ds.selectedOptionsForReadOnly = new List<Selectoption>();
        ds.selectedOptionsForVisibleOnly = new List<Selectoption>();
        createStructureForLayoutAssignment(new List<DataStructure>{ds});
        createStructureForFLS(new List<DataStructure>{ds});
        isObjectNameEditable=false;
        dsList.add(ds);
        return null;
    }
    
    public PageReference onClickDelete()
    {
        Integer index = Integer.valueof(system.currentpagereference().getparameters().get('index'));
        List<DataStructure> dsToRemove = new List<DataStructure>();
        if(dsList[index-1] != null)
        {
            System.debug('@DS***:'+dsList[index-1].fieldType);
            dslist.remove(index-1);
        }
        PageReference pageref = new PageReference('/apex/MetadataDemoPageNew');
        return null;
    }
    
    public PageReference callFLSPage()
    {
        
        PageReference pageref = new PageReference('/apex/FieldLevelSecurityPage');
        return pageref;
    }
    
  
    /*****************************************************************************************************************************************************/       
    Boolean isgetallSobjectsCalled = false;
    public List<SelectOption> getallSobjects()
    {
        
        if(!isgetallSobjectsCalled)
        {
            allSobjects = UtilityClass.getAllSObject();
            isgetallSobjectsCalled = true;
        }
        if(allSobjects.size() > 0)
            return allSobjects;
        else 
            return null;
    }
    
    /*****************************************************************************************************************************************************/       
    public List<DataStructure> getdsList()
    {
        if (dsList!= NULL) {
            if (dsList.size() > 0)
                return dsList;
            else
                return null;  
        }                   
        else
            return null;
        
    }
    
    /*****************************************************************************************************************************************************/       
    public Boolean getisCreateFieldCalled()
    {
        return isCreateFieldCalled;
    }
    
    /*****************************************************************************************************************************************************/       
    public void validate()
    {
        Boolean isValidationComplete=Validatedata.validateDataBeforeSubmit(dsList);
        if(isValidationComplete)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Validation Error. Please proceed to create fields.')); 
        }
    }
    
    /*****************************************************************************************************************************************************/       
    public PageReference validateAndSubmit()
    {
        Boolean isValidationComplete=Validatedata.validateDataBeforeSubmit(dsList);
        hideExtraColumnsAfterFinalSubmit=true;
        hideSubmitSection=true;
        if(isValidationComplete)
        {
            validationCompleteLabel=true;            
            PageReference reviewPage=new pageReference('/apex/ReviewMetadataDemo');
            return reviewPage;
        }
        return null;
    }
    
    /*****************************************************************************************************************************************************/       
    public PageReference ignoreErrorsAndSubmit()
    {
        hideSubmitSection=true;
        validationCompleteLabel=false;
        hideExtraColumnsAfterFinalSubmit=true;
        PageReference reviewPage=new pageReference('/apex/ReviewMetadataDemo');
        return reviewPage;
    }
    /*****************************************************************************************************************************************************/
    public void finalSubmit()
    {
        hideSubmitSection=false;
        showErrorColumns=true;
        hideExtraColumnsAfterFinalSubmit=false;
        createField();
        
        disableSubmitAndCancelBtnOnReviewPage=true;
        for(DataStructure ds: dsList)
        {
            if(ds.result=='Success')
            {
                successList.add(ds);
            }
            else if(ds.result=='error')
            {
                errorList.add(ds);
            }
        }
        successListSize=successList.size();
        errorListSize=errorList.size();
    }
    /*****************************************************************************************************************************************************/    
    public PageReference goToPreviousPage()
    {
        isCancelCalled = true;
        PageReference previousPage = new PageReference('/apex/MetadataDemoPageNEW');
        return previousPage;
    }
    
    /*****************************************************************************************************************************************************/     
    public pageReference DownloadSuccessExcel(){
        PageReference exDownloadSuccess = null;
        exDownloadSuccess = Page.ExcelDownload;
        exDownloadSuccess.setRedirect(false);
        successList.clear();
        
        for(DataStructure ds: dsList)
        {
            if(ds.result=='Success')
            {
                successList.add(ds);
            }
        }
        return exDownloadSuccess;
    }
    /*****************************************************************************************************************************************************/     
    public pageReference DownloadErrorExcel(){
        PageReference exDownloadError = null;
        exDownloadError = Page.ExcelDownloadError;
        exDownloadError.setRedirect(false);
        errorList.clear();
        
        for(DataStructure ds: dsList)
        {
            if(ds.result=='error')
            {
                errorList.add(ds);
            }
        }
        return exDownloadError;
    }
    /*****************************************************************************************************************************************************/     
    public List<DataStructure> getsuccessList()
    {
        return successList;
    }
    
    /*****************************************************************************************************************************************************/
    public List<DataStructure> geterrorList()
    {
        return errorList;
    }
    /*****************************************************************************************************************************************************/
    public Boolean getshowDownloadFilesButton()
    {
        return false;	
    }
    /*****************************************************************************************************************************************************/    
    public Boolean getvalidationCompleteLabel()
    {
        return false;
    }
    /*****************************************************************************************************************************************************/    
    public Boolean getdisableSubmitAndCancelBtnOnReviewPage()
    {
        return false;
    }
    /*****************************************************************************************************************************************************/   
    public Boolean gethideSubmitSection()
    {
        return true;
    }
    /*****************************************************************************************************************************************************/    
    public Boolean getshowErrorColumns()
    {
        return false;
    }
    /*****************************************************************************************************************************************************/    
    public Boolean hideExtraColumnsAfterFinalSubmit()
    {
        return true;
    }
    /*****************************************************************************************************************************************************/
	public void setApplytoAllPopUp() 
    {
        System.debug('@@@@test11111'+showApplyToAllPopUp);
    	showApplyToAllPopUp = true;
        System.debug('@@@@test22222'+showApplyToAllPopUp);
    }
    /*****************************************************************************************************************************************************/
    public void unsetApplytoAllPopUp()
    {
     	showApplyToAllPopUp = false;   
    }
    /*****************************************************************************************************************************************************/
    public void applyFLSToAll()
    {
        system.debug('Here in applyFLSToAll');
        for(DataStructure ds:dsList)
        {
            ds.selectedOptionsForReadOnly.clear();
            
            ds.selectedOptionsForReadOnly.addAll(selectedReadOnlyList);
            ds.allOptionsForReadOnly.addAll(allPofileReadOnlylist);
            ds.selectedOptionsForVisibleOnly.addAll(selectedVisibleList);
            ds.allOptionsForVisibleOnly.addAll(allPofileVisibleList);
        }
    }
}