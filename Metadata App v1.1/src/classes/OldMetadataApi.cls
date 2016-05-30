public class OldMetadataApi {    
    
    private static set<String> dataTypeContainsPrecisionField= new set<String>{'Number','Percent','Currency'};     
    static List<MetadataService.SaveResult> results=new List<MetadataService.SaveResult>();
    static List<MetadataService.DeleteResult> deleteResult=new List<MetadataService.DeleteResult>();
    
    
    public static void createField(LIST<DataStructure> dsList)
    {
        MetadataService.MetadataPort service = createService();
        
        for(DataStructure ds:dsList)    
        {
            MetadataService.CustomField customField = new MetadataService.CustomField();
            
            try{
                customField.type_x = ds.fieldType;
                customField.label = ds.fieldLabel;
                customField.fullName = ds.objectName+'.'+ds.fieldName;
                
                if(ds.length!=null && dataTypeContainsPrecisionField.contains(ds.fieldType))
                    customField.precision=ds.length;
                else if(ds.length!=null)                
                    customField.length=ds.length;                 
                
                if(ds.decimalPlace!=null)                  
                    customField.scale = ds.decimalPlace ;
                
                if(ds.visibleLines!=null)
                    customField.visibleLines = ds.visibleLines;
                
                if(ds.pickListValues!=null)                    
                    customField=createPicklist(customField,ds);
                
                if(ds.fieldDefaultValue!=null)                
                    customField.defaultValue=ds.fieldDefaultValue;
                
                if(ds.required!=null)                
                    customField.required = ds.required;
                
                if(ds.trackFeedHistory !=null)                
                    customField.trackFeedHistory = ds.trackFeedHistory ;
                
                if(ds.unique!=null)
                {
                    //System.debug('Unique'+ds.fieldType);
                    customField.unique = ds.unique;
                }
                if(ds.childRelationshipName!=null && ds.relatedListLabel!=null && ds.relatedToObject!=null)
                {
                    createLookupField(ds, customField);
                } 
                
                if(ds.externalId!=null)
                    customField.unique = ds.externalId;
                
                customField.description=ds.description;
                customField.inlineHelpText=ds.helpText;
                results = service.createMetadata(new MetadataService.Metadata[] { customField });
                handleSaveResults(results[0],ds);
                //System.debug(''+results[0]);
            }
            catch(Exception e)
            {
                ds.result='Error';
                ds.errorMsg=e.getMessage();
                System.debug('Error Message:'+e);
            }        
        }    
    }
    
    public static MetadataService.CustomField createPicklist( MetadataService.CustomField customField, DataStructure ds)
    {
        
        Metadataservice.Picklist pt = new Metadataservice.Picklist();
        pt.sorted= ds.picklistSorted;
        String[] picklistValue=ds.picklistValue.split('\n');
        System.debug('After Split PickListValue:'+picklistValue);
        List<MetadataService.PicklistValue> pickValues=new List<MetadataService.PicklistValue>();
        for(String str:picklistValue)
        {
            metadataservice.PicklistValue pv = new metadataservice.PicklistValue();                   
            pv.fullName = str;
            pv.default_x=false ;
            System.debug(pv);
            pickValues.add(pv);
        }
        System.debug('After Insert PickListValue'+pickValues);
        pt.picklistValues = pickValues;
        customField.picklist = pt ;
        return customField;        
    }
    
    public static void createLookupField(DataStructure ds, MetadataService.CustomField customField)
    { 
        customField.fullName = customField.fullName;
        customField.label = ds.fieldLabel;
        customField.type_x = ds.fieldType;
        customField.relationshipLabel = ds.relatedListLabel;
        customField.relationshipName = ds.relatedListLabel;
        customField.referenceTo = ds.relatedToObject;
        
    }
    
    public static List<MetadataService.DeleteResult> deleteField(List<DataStructure> dsList)
    {
        MetadataService.MetadataPort service = createService();
        List<String> fieldsToDelete=new List<String>(); 
        for(DataStructure ds:dsList)
        {
            fieldsToDelete.add(ds.objectName+'.'+ds.fieldName);
        }
        try{
            List<String> tempStr=new List<String>();
            Integer tempCount=0;
            for(String str:fieldsToDelete)
            {
                System.debug('String:'+str);
                
                if(tempCount<9)
                {
                    tempCount++;
                    tempStr.add(str);
                }
                else{
                    tempCount=0;
                    tempStr.add(str);
            		deleteResult.addAll(service.deleteMetadata('CustomField',tempStr));
                    tempStr.clear();
                }
            }
            if(tempStr.size()>0 && !tempStr.isEmpty())
            	deleteResult.addAll(service.deleteMetadata('CustomField',tempStr));
            	System.debug('***********'+deleteResult);
           
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            System.debug('Exception:'+e);
        }
         return deleteResult;
        
    }
    
    
    public static Set<String> fetchAllProfile()
    {
        Set<String> profileSet=new Set<String>();
        MetadataService.MetadataPort service = createService();     
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryProfile = new MetadataService.ListMetadataQuery();
        queryProfile.type_x = 'Profile';
        queries.add(queryProfile);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        System.debug(fileProperties[0]);
        for(MetadataService.FileProperties fileProperty : fileProperties)
        {
            System.debug(fileProperty.fullName);
            profileSet.add(fileProperty.fullName);
        }
        
        return profileSet;
    }
    public static Map<String, List<String>> fetchAllLayouts()
    {
        Map<String, List<String>> objectLayoutMap=new  Map<String, List<String>>();
    	
        MetadataService.MetadataPort service = createService();     
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.type_x = 'Layout';
        queries.add(queryLayout);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        //System.debug(fileProperties[0]);
        for(MetadataService.FileProperties fileProperty : fileProperties)
        {
            List<String> tempStrList=new List<String>();
            tempStrList=fileProperty.fullName.split('-');
            //System.debug(tempStrList);
            List<String> valueOfMap=new LIST<String>();
            if(objectLayoutMap.containsKey(tempStrList[0]))
            {                
                valueOfMap = objectLayoutMap.get(tempStrList[0]);
                valueOfMap.add(tempStrList[1]);
            }
            else
            {
                valueOfMap.add(tempStrList[1]);
            }
            objectLayoutMap.put(tempStrList[0], valueOfMap);   
        }
        return objectLayoutMap;
        //System.debug('Map:'+objectLayoutMap);
        
    }
    
    public static void updateFieldLevelSecurity(List<DataStructure> dsList)
    {
        MetadataService.MetadataPort service = createService();
        Map<String, Set<String>> masterMap=new Map<String,Set<String>>();
        System.debug('DSLIST:'+dsList.size()+dsList);
        for(DataStructure ds:dsList)
        {
            //System.debug('DS:'+ds.fieldName);
            //System.debug('selectedOptionsForReadOnly---'+ds.selectedOptionsForReadOnly);
            for(SelectOption so:ds.selectedOptionsForReadOnly)
            {
                MetadataService.Profile pro = new MetadataService.Profile();
                pro.fullName=so.getValue();
                MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
                fieldSec.field=ds.objectName+'.'+ds.fieldName;
                fieldSec.editable=false;
                fieldSec.readable=true;
                pro.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;
                    List<MetadataService.SaveResult> res = service.updateMetadata(new MetadataService.Metadata[] {pro});
                handleSaveResults(results[0],ds);
                System.debug('*******************************Inside 1'+results[0]);
                
            }
            for(SelectOption so:ds.selectedOptionsForVisibleOnly)
            {
                System.debug('DS:'+ds.fieldName);
                System.debug('selectedOptionsForReadOnly---'+ds.selectedOptionsForVisibleOnly);
                MetadataService.Profile pro = new MetadataService.Profile();
                pro.fullName=so.getValue();
                MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
                fieldSec.field=ds.objectName+'.'+ds.fieldName;
                fieldSec.editable=true;
                fieldSec.readable=true;
                pro.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;
                    List<MetadataService.SaveResult> res = service.updateMetadata(new MetadataService.Metadata[] {pro});
                handleSaveResults(results[0],ds);
                System.debug('*******************************Inside 2'+results[0]);
            }
        }
        return;
    }
    
    public static void addFieldToLayout(List<DataStructure> dsList)
    {
        MetadataService.MetadataPort service = createService();
        for(DataStructure ds:dsList)
        {
            List<String> layoutList= new List<String>();
            if(ds.selectedOptionsForLayoutAssignment!=null && !ds.selectedOptionsForLayoutAssignment.isEmpty() && !ds.required)
            {
                for(SelectOption so:ds.selectedOptionsForLayoutAssignment)
                {
                    if(so.getValue()!=null)
                    {
                        String layoutName=ds.objectName+'-'+so.getValue();
                        layoutList.add(layoutName);
                        
                    }
                }
            }
            if(layoutList.size()>0 && !layoutList.isEmpty())
            {
                for(String str:layoutList)
                {
                    try{
                        MetadataService.Layout layout =(MetadataService.Layout) service.readMetadata('Layout',new String[]{str}).getRecords()[0];
                        //System.debug('Layout:'+layout);    
                        // Add Layout section, layout, item and field
                        if(layout.layoutSections==null)
                            layout.layoutSections = new List<MetadataService.LayoutSection>();
                        
                        MetadataService.LayoutSection layoutSec = layout.layoutSections[0];
                        //newLayoutSection.style = 'OneColumn';
                        MetadataService.LayoutColumn newLayoutColumn = layoutSec.LayoutColumns[0];
                        MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
                        newLayoutItem.field = ds.fieldName;
                        newLayoutColumn.layoutItems.add(newLayoutItem );
                        // System.debug(''+ds.fieldName+'::::'+newLayoutItem.field);
                        //layoutSec.layoutColumns.add(newLayoutColumn);
                        //layout.layoutSections.add(layoutSec);
                        
                        handleSaveResults(
                            service.updateMetadata(
                                new MetadataService.Metadata[] { layout })[0],ds);
                    }
                    catch(Exception e)
                    {
                        
                        
                        System.debug('error:'+e);
                    }
                }
            }
            
        }
        
        
    }
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult,DataStructure ds)
    {
        if(saveResult==null || saveResult.success)
        {
            ds.result='Success';
            return;
        }   
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();               
            for(MetadataService.Error error : saveResult.errors)
                messages.add(error.message);
            if(messages.size()>0)
            {
                throw new MetadataExampleFieldCreationException(String.join(messages, ' '));
            }               
        }
        else{
            if(!saveResult.success)
            {
                throw new MetadataExampleFieldCreationException('Request failed with no specified error.');
            }
        }      
    }
    
    public class MetadataExampleFieldCreationException extends Exception { }
    
    
}