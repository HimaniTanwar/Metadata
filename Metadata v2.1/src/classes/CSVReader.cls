public class CSVReader  {
    
    public string nameFile{get;set;}
    public String check{get;set;}
    public Blob contentFile{get;set;}
    private List<DataStructure> dsList=new LIST<DataStructure>();
    public  String dataType{get;set;}
    public  LIST<SelectOption> dataTypeList=new LIST<SelectOption>();
    public Boolean isCreateFieldCalled=false;   
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
    public Boolean isDownloadSuccessFile{get;set;}
    Boolean isgetallSobjectsCalled = false;
    public List<selectoption> selectedReadOnlyList{get;set;}
    public List<selectoption> selectedVisibleList{get;set;}
    public List<selectoption> profileList{get;set;}
    CSVReaderHelperClass helper = new CSVReaderHelperClass();
    /*****************************************************************************************************************************************************/   
    public CSVReader(){
        
        isCancelCalled=false;
        isRenderErrorResult=false;
        selectedVisibleList = new List<selectOption>();
        selectedReadOnlyList = new List<selectOption>();
        
    }
    
    /*****************************************************************************************************************************************************/           
    public Pagereference ReadFile(){           
        try
        {           
            PageReference secondPage = new PageReference('/apex/MetadataDemoPageNEW');
            nameFile=contentFile.toString();                //ContentFile Contains Data in BLOB Format
            String[] inputValues=nameFile.split('\n');      //Spliting Each Row of CSV File           
            dsList=helper.createStructure(inputValues);
            profileList = new List<SelectOption>();
            profileList.addAll(dsList[0].allOptionsForReadOnly);
            System.debug('@@@@@@@'+dsList.size());
            return secondPage;
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
            return null;
        }
    }
    /*****************************************************************************************************************************************************/       
    //On Submit button Action pass date to MetadataApi Class to create Fields, Apply FLS, and add to PageLayout
    public PageReference createField()
    {
        isCreateFieldCalled=true;
        isObjectNameEditable=true;
        showDownloadFilesButton=true;
        MetadataApi.createField(dsList);
        MetadataApi.updateFieldLevelSecurity(dsList);
        MetadataApi.addFieldToLayout(dsList);
        return null;
    }
    
    public  List<SelectOption> getdataTypeOptions(){
        if(!isgetdataTypeOptions){
            dataTypeOptions = UtilityClass.getAllFieldType();
            isgetdataTypeOptions=true;
        }
        return dataTypeOptions;
    }    
    /*****************************************************************************************************************************************************/          
    public void changeStructure(){
        helper.createStructureForLayoutAssignment(this.dsList);
        for(DataStructure ds: dsList){
            System.debug('ds.fieldType'+ds.fieldType +'*********'+'ds.changedDataType'+ds.changedDataType);
            if(ds.fieldType != ds.changedDataType){
                ds.fieldType = ds.changedDataType;
                UtilityClass.changeStructure(ds);
            }
        }
    }
    
    /*****************************************************************************************************************************************************/           
    public PageReference initialState(){
        for(DataStructure ds:dsList){
            if(ds.isUpdatable){
                if(ds.changedDataType != ds.fieldType){
                    ds.changedDataType=ds.fieldType;
                }
            }
        }
        return null;
    }
    
    /*****************************************************************************************************************************************************/       
    public void applyReadonlyToAllProfiles(){ 
        List<SelectOption> listFirstSelectedProfile=new List<SelectOption>();
        listFirstSelectedProfile=dsList[0].selectedOptionsForReadOnly;
        for(Integer i = 1; i < dsList.size(); i++){
            DataStructure ds = dsList.get(i);
            ds.selectedOptionsForReadOnly.clear();
            ds.selectedOptionsForReadOnly.addAll(listFirstSelectedProfile);
        }       
    }
    
    /*****************************************************************************************************************************************************/        
    public void applyVisibleToAllProfiles(){
        List<SelectOption> listFirstSelectedProfile=new List<SelectOption>();
        listFirstSelectedProfile=dsList[0].selectedOptionsForVisibleOnly;
        for(Integer i = 1; i < dsList.size(); i++){
            DataStructure ds = dsList.get(i);
            ds.selectedOptionsForVisibleOnly.clear();
            ds.selectedOptionsForVisibleOnly.addAll(listFirstSelectedProfile);
        }  
    }
    
    /*****************************************************************************************************************************************************/            
    public PageReference addNewRowInTable(){
        Map<String, List<String>> objectLayoutMap=new  Map<String, List<String>>();
        DataStructure ds=new DataStructure();
        ds.selectedOptionsForLayoutAssignment = new List<Selectoption>();
        ds.selectedOptionsForReadOnly = new List<Selectoption>();
        ds.selectedOptionsForVisibleOnly = new List<Selectoption>();
        helper.createStructureForLayoutAssignment(new List<DataStructure>{ds});
        helper.createStructureForFLS(new List<DataStructure>{ds});
        isObjectNameEditable=false;
        dsList.add(ds);
        return null;
    }
    
    public PageReference onClickDelete(){
        Integer index = Integer.valueof(system.currentpagereference().getparameters().get('index'));
        List<DataStructure> dsToRemove = new List<DataStructure>();
        if(dsList[index-1] != null){
            System.debug('@DS***:'+dsList[index-1].fieldType);
            dslist.remove(index-1);
        }
        PageReference pageref = new PageReference('/apex/MetaDataPageUITest');
        return null;
    }
    
    public PageReference callFLSPage(){        
        PageReference pageref = new PageReference('/apex/FieldLevelSecurityPage');
        return pageref;
    }
    /*****************************************************************************************************************************************************/           
    public List<SelectOption> getallSobjects(){      
        if(!isgetallSobjectsCalled){
            allSobjects = UtilityClass.getAllSObject();
            isgetallSobjectsCalled = true;
        }
        if(allSobjects.size() > 0)
            return allSobjects;
        else 
            return null;
    }
    
    /*****************************************************************************************************************************************************/       
    public List<DataStructure> getdsList(){
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
    public Boolean getisCreateFieldCalled(){
        return isCreateFieldCalled;
    }
    
    /*****************************************************************************************************************************************************/       
    public void validate(){
        MetadataApi.fetchTrackFeedHistory(dsList);
        Boolean isValidationComplete=Validatedata.validateDataBeforeSubmit(dsList);
        for(DataStructure ds: dsList){
            if(ds.picklistValue!=null && ds.picklistValue!=''){
                System.debug('character picklist values length@@'+ ds.picklistValue.trim().length());
                System.debug('ds.picklistValue@@'+ds.picklistValue);
                System.debug('ds.picklistValues@@@@@'+ds.picklistValues);
                //       ds.picklistValue.replace(' ','$%^');
            }
        }
        if(isValidationComplete){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Validation Error. Please proceed to create fields.')); 
        }
    }
    
    /*****************************************************************************************************************************************************/       
    public PageReference validateAndSubmit(){
        Boolean isValidationComplete=Validatedata.validateDataBeforeSubmit(dsList);
        hideExtraColumnsAfterFinalSubmit=true;
        hideSubmitSection=true;
        if(isValidationComplete){
            validationCompleteLabel=true;              
            PageReference reviewPage=new pageReference('/apex/ReviewMetadataDemo');
            return reviewPage;
        }
        return null;
    }
    
    /*****************************************************************************************************************************************************/       
    public PageReference ignoreErrorsAndSubmit(){
        hideSubmitSection=true;
        validationCompleteLabel=false;
        hideExtraColumnsAfterFinalSubmit=true;
        PageReference reviewPage=new pageReference('/apex/ReviewMetadataDemo');
        return reviewPage;
    }
    /*****************************************************************************************************************************************************/
    public void finalSubmit(){
        hideSubmitSection=false;
        showErrorColumns=true;
        hideExtraColumnsAfterFinalSubmit=false;
        createField();
        
        disableSubmitAndCancelBtnOnReviewPage=true;
        for(DataStructure ds: dsList){
            if(ds.result=='Success'){
                successList.add(ds);
            }
            else if(ds.result=='error'){
                errorList.add(ds);
            }
        }
        successListSize=successList.size();
        errorListSize=errorList.size();
    }
    /*****************************************************************************************************************************************************/    
    public PageReference goToPreviousPage(){
        isCancelCalled = true;
        PageReference previousPage = new PageReference('/apex/MetaDataPageUITest');
        return previousPage;
    }
    
    /*****************************************************************************************************************************************************/     
    public PageReference goToUploadCSVPage(){
        PageReference uploadCSVPage = new PageReference('/apex/MainFileUploadPageNEW');
        return uploadCSVPage;
    }
    
    public PageReference goToEditPage(){
        PageReference editPage = new PageReference('/apex/MetadataDemoPageNEW');
        return editPage;
    }
    /*****************************************************************************************************************************************************/     
    
    public pageReference ExportDataInCSVFile(){
        isDownloadSuccessFile=false;
        PageReference exDownloadSuccess = null;
        exDownloadSuccess = Page.ExcelDownload;
        exDownloadSuccess.setRedirect(false);
        System.debug('isDownloadSuccessFile1'+isDownloadSuccessFile);
        for(DataStructure ds: dsList){
            successList.add(ds);
        } 
        System.debug('isDownloadSuccessFile2'+isDownloadSuccessFile);
        return exDownloadSuccess;
    }
    /*****************************************************************************************************************************************************/     
    
    public pageReference DownloadSuccessExcel(){
        isDownloadSuccessFile=true;
        PageReference exDownloadSuccess = null;
        exDownloadSuccess = Page.ExcelDownload;
        exDownloadSuccess.setRedirect(false);
        successList.clear();
        System.debug('isDownloadSuccessFile3'+isDownloadSuccessFile);
        for(DataStructure ds: dsList){
            if(ds.result=='Success'){
                successList.add(ds);
            }
        } 
        System.debug('isDownloadSuccessFile4'+isDownloadSuccessFile);
        return exDownloadSuccess;
    }
    /*****************************************************************************************************************************************************/     
    public pageReference DownloadErrorExcel(){
        PageReference exDownloadError = null;
        exDownloadError = Page.ExcelDownloadError;
        exDownloadError.setRedirect(false);
        errorList.clear();       
        for(DataStructure ds: dsList){
            if(ds.result=='error'){
                errorList.add(ds);
            }
        }
        return exDownloadError;
    }
    /*****************************************************************************************************************************************************/     
    public List<DataStructure> getsuccessList(){
        return successList;
    }
    
    /*****************************************************************************************************************************************************/
    public List<DataStructure> geterrorList(){
        return errorList;
    }
    /*****************************************************************************************************************************************************/
    public Boolean getshowDownloadFilesButton(){
        return false;   
    }
    /*****************************************************************************************************************************************************/    
    public Boolean getvalidationCompleteLabel(){
        return false;
    }
    /*****************************************************************************************************************************************************/    
    public Boolean getdisableSubmitAndCancelBtnOnReviewPage(){
        return false;
    }
    /*****************************************************************************************************************************************************/   
    public Boolean gethideSubmitSection(){
        return true;
    }
    /*****************************************************************************************************************************************************/    
    public Boolean getshowErrorColumns(){
        return false;
    }
    /*****************************************************************************************************************************************************/    
    public Boolean hideExtraColumnsAfterFinalSubmit(){
        return true;
    }
    /*****************************************************************************************************************************************************/
    public void setApplytoAllPopUp(){
        System.debug('@@@@test11111'+showApplyToAllPopUp);
        showApplyToAllPopUp = true;
        System.debug('@@@@test22222'+showApplyToAllPopUp);
    }
    /*****************************************************************************************************************************************************/
    public void unsetApplytoAllPopUp(){
        showApplyToAllPopUp = false;   
    }
    /*****************************************************************************************************************************************************/
    public void applyFLSToAll(){
        system.debug('Here in applyFLSToAll');
        for(DataStructure ds:dsList)
        {
            ds.selectedOptionsForReadOnly.clear();           
            ds.selectedOptionsForReadOnly.addAll(selectedReadOnlyList);
            //ds.allOptionsForReadOnly.addAll(allPofileReadOnlylist);
            ds.selectedOptionsForVisibleOnly.addAll(selectedVisibleList);
            //ds.allOptionsForVisibleOnly.addAll(allPofileVisibleList);
        }
    }
    /*****************************************************************************************************************************************************/       
    public PageReference assignPageLayout(){
        dsList=helper.createStructureForLayoutAssignment(dsList);
        PageReference reviewPage=new pageReference('/apex/PageLayoutAssignPage');
        return reviewPage;
    }
    /*****************************************************************************************************************************************************/       
    public PageReference cancleFromFLSPage(){
        PageReference reviewPage=new pageReference('/apex/MetadataDemoPageNEW');
        return reviewPage;
    }
    /*****************************************************************************************************************************************************/       
    public PageReference cancleFromPageLayoutPage(){
        PageReference reviewPage=new pageReference('/apex/FieldLevelSecurityPage');
        return reviewPage;
    }
    
    /*****************************************************************************************************************************************************/           
    public Boolean getisDownloadSuccessFile(){
        return false;
    }
}