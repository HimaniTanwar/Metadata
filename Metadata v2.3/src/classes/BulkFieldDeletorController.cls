public class BulkFieldDeletorController {
    
    private  Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private  List<SelectOption> objNames = new List<SelectOption>();
    public  String selectedObject{get;set;}
    private  List<DataStructure> dsList=new LIST<DataStructure>();
    private  List<DataStructure> dsListToDelete=new LIST<DataStructure>();
    private Boolean isgetObjCalled=false;
    private Boolean isgetdsListCalled=false;
    private  String pageBlockSectionTitle{get;set;}
    public Boolean isObjectSelected{get;set;}
    public Boolean clearPreviousRecords{get;set;}
    public Boolean disableDeleteButtonAfterDeletion{get;set;}
    public  List<DataStructure> dsList2{get;set;}//=new LIST<DataStructure>();
    private Boolean isCancelCalled = false;
   
    public List<AggregateResult> obj{get;set;}
    
    public PageReference createObjSelectOption()
    {
        System.debug('Inside createObjSelectOption');
        isgetdsListCalled=false;
        clearPreviousRecords=true;
        disableDeleteButtonAfterDeletion=false;
        objNames.addAll(UtilityClass.getAllSObject());
        return null;
    }
    
    public PageReference goToSecondPage()
    {
        PageReference secondPage = new PageReference('/apex/BlukFieldDeletorWarningScreen');
      //  PageReference pageRef = ApexPages.currentPage();
        List<String> fieldsToDelete=new LIST<String>();
        isCancelCalled= false;
        dsListToDelete.clear();
        for(DataStructure ds:dsList)
        {
            if(ds.isDeletable)
            {
                ds.objectName=selectedObject;
                fieldsToDelete.add(ds.fieldName);
                dsListToDelete.add(ds);
            }
        }
       
        if(dsListToDelete.isEmpty() || dsListToDelete.size()==0 || dsListToDelete==NULL)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select some fields to delete!!!'));
         	return null;
        }
        else
        {
            dsList2=new LIST<DataStructure>(dsList);
            System.debug('dsList@@@@@@'+dsList.size());

            if(clearPreviousRecords)
            {
                dsList.clear();
            }
            
            if(!dsListToDelete.isEmpty() && dsListToDelete.size()>0)
                isgetdsListCalled=true;

            return secondPage;
        }
        
    }
    
    public PageReference goToFirstPage()
    {
		isCancelCalled = true;
        PageReference firstPage = new PageReference('/apex/BulkFieldDeletorNew');
        return firstPage;
    }
    
    public  List<SelectOption> getobjNames() 
    {
        System.debug('getobjNames'+isgetObjCalled);
        if(!isgetObjCalled)
        {
            isgetObjCalled=true;
            createObjSelectOption();
        }
        return objNames;
    }
    
    public PageReference createDataStructur()
    {
        dsList.clear();
        System.debug('createDataStructur$$'+selectedObject);
        Map<String,Schema.SObjectField> fieldMap=schemaMap.get(selectedObject).getDescribe().fields.getMap();
        System.debug('Fields:'+fieldMap);
       
        for(Schema.SObjectField sfield:fieldMap.values())
        {
            System.debug('Inside Loop sfield@@@'+ sfield);
            DataStructure ds=new DataStructure();
            if(String.valueOf(sfield).contains('__c'))
            {
                
                ds.fieldLabel=sfield.getDescribe().getLabel();
                ds.fieldName=sfield.getDescribe().getLocalName();
                ds.fieldType=String.valueOf(sfield.getDescribe().getType());
                ds.unique=sfield.getDescribe().isUnique();
                ds.isDeletable=false;
                ds.isEditable=false;
                dsList.add(ds);
            }
            System.debug('Inside Loopds.fieldLabel@@@'+ ds.fieldLabel);
            isObjectSelected=true;
        }
        return null;
        //MetadataService.IReadResult readReasult=MetadataApi.readFieldsOfObject(selectedObject);
        //MetadataService.Metadata[] mdinfo=readReasult.getRecords();
    }
    public Integer total {get; set;}

    /*public void countRecords(Map<String,Schema.SObjectField> fieldMap)
    {
        System.debug('fieldmap@@@@@'+fieldMap);
        Map<String, List<AggregateResult>> mapFieldNameAndTheirCount = new Map<String, List<AggregateResult>>();
        List<String> fieldAPINameList = new List<String>();
        for(Schema.SObjectField sfield:fieldMap.values())
        {
            String s=String.valueOf(sfield);
            System.debug('String conversion of sfield@@@@@'+s);
            if(String.valueOf(sfield).contains('__c'))
            {
                String soqlQuery = 'select count(' + s + ',)total from Account';
                obj = database.query(soqlQuery);
                System.debug('database.query conversion of aggregate result@@'+obj);
                mapFieldNameAndTheirCount.put(s, obj);
            }
            
        }
        System.debug('mapFieldNameAndTheirCount@@     '+mapFieldNameAndTheirCount);
        for(AggregateResult ar: obj)
        {
            System.debug('obj@@'+obj);
            System.debug('ar@@'+ar);
            total = (Integer) ar.get('total');
        }

        System.debug('ds.count@@@@@@@@@@@'+total);
    }*/
    
    
    public List<DataStructure> getFields()
    {
        System.debug('Inside getFields');        
        return dsList;   
    }
    
    public  PageReference deleteSelectedField()
    {
        disableDeleteButtonAfterDeletion=true;
        System.debug('*****Inside deleteSelectedField*********');
        List<String> fieldsToDelete=new LIST<String>();
        for(DataStructure ds:dsList)
        {
            if(ds.isDeletable)
            {
                ds.objectName=selectedObject;
                fieldsToDelete.add(ds.fieldName);
                dsListToDelete.add(ds);
                System.debug(ds.fieldName);
                
            }
        }
        List<MetadataService.DeleteResult> deleteResultList=MetadataApi.deleteField(dsListToDelete);
        handleDeleteResult(deleteResultList);
     //   System.debug('deleteResultList@@'+deleteResultList);
        if(!dsListToDelete.isEmpty() && dsListToDelete.size()>0)
        {isgetdsListCalled=true;
         // removeCancelButtonAfterDeletion=false;
         //removeDeletedFieldFromList();
        }
        System.debug('New Ds List:'+dsList);
        return null;
    }
    
    public void handleDeleteResult(List<MetadataService.DeleteResult> deleteResultList)
    {
        for(MetadataService.DeleteResult dr:deleteResultList)
            System.debug('FullName:'+dr.fullName);
        
        if(!deleteResultList.isEmpty() && deleteResultList.size()>0)
        {
            System.debug(''+deleteResultList.size());
            Integer delResultCount=0;
            for(DataStructure ds:dsListToDelete)
            {
                if(delResultCount<deleteResultList.size())
                {
                    System.debug('dsFieldName'+ds.fieldName);
                    System.debug('deleteResult'+deleteResultList[delResultCount].fullName);
                    
                    if(deleteResultList[delResultCount]==null || deleteResultList[delResultCount].success)
                        ds.result='Success';
                    
                    if(deleteResultList[delResultCount].errors!=null)
                    {
                        ds.result='Error';
                        List<String> messages = new List<String>();               
                        for(MetadataService.Error error : deleteResultList[delResultCount].errors)
                            messages.add(error.message);
                        if(messages.size()>0)
                            ds.errorMsg=(String.join(messages, ' '));
                        
                    }
                    else{
                        if(!deleteResultList[delResultCount].success)
                            ds.errorMsg='Request failed with no specified error.';
                    }
                }
                delResultCount++;
            }
        }
    }
    public static Boolean checkboxState{get;set;}
    public void applyToAll()
    {
        if(checkboxState){
            System.debug('Called applyToAll');
        //    listFirstSelectedProfile=dsList[0].isDeletable;
           // System.debug('listFirstSelectedProfile**' + listFirstSelectedProfile);
            
            for(Integer i = 0; i < dsList.size(); i++)
            {
                DataStructure ds = dsList.get(i);
               // ds.selectedOptionsForReadOnly.clear();
                ds.isDeletable=true;
            }
        }
        else
        {
            for(Integer i = 0; i < dsList.size(); i++)
            {
                DataStructure ds = dsList.get(i);
               // ds.selectedOptionsForReadOnly.clear();
                ds.isDeletable=false;
            }
        }
    }
    
    
    
    public  List<DataStructure> getdsList()
    {
        System.debug('Inside getdsList: '+dsList);
        if(isgetdsListCalled && !isCancelCalled)
        {
            pageBlockSectionTitle='Deleted Fields';
            system.debug('@1 condition1');
            return dsListToDelete;
        }
        else if(isCancelCalled)
        {
            pageBlockSectionTitle='Fields Can be Deleted';
            system.debug('@2 condition2');
            dsList = dsList2;
            return dsList;
        }
        else
        {
            pageBlockSectionTitle='Fields Can be Deleted';
            system.debug('@3 condition3');
            return dsList;
        }

          
        
    }
    public String getpageBlockSectionTitle()
    {
        return pageBlockSectionTitle;
    }
    public Boolean getisgetdsListCalled()
    {
        return isgetdsListCalled;
    }
    
}