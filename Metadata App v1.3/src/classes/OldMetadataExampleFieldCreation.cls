public class OldMetadataExampleFieldCreation {
    
    private static set<String> dataTypeContainsLengthField = new set<string>{'Text','LongTextArea','Html'};
    private static set<String> dataTypeContainsPrecisionField= new set<String>{'Number','Percent','Currency'};  
    private static set<String> dataTypeContainsDecimalPlaceField = new set<String>{'Number','Percent','Currency','Location'};
    private static set<String> dataTypeContainsVisibleLinesField = new set<String>{'PickList','MultiselectPicklist','LongTextArea','Html'};
    private static set<String> dataTypeNotContainsRequiredField = new set<String>{'Checkbox','LongTextArea','Html','Picklist','MultiselectPicklist'};
    private static set<String> dataTypeNotContainsDefaultField = new set<String>{'Html','Location','Picklist','MultiselectPicklist'};
    private static set<String> dataTypeContainsUniqueField = new set<String>{'Email','Number','Text'};
    private static set<String> dataTypeContainsExternalIDField = new set<String>{'Email','Number','Text'};
        
    static List<MetadataService.SaveResult> results=new List<MetadataService.SaveResult>()  ;
        
    public static void createField(String[] inputvalues)
    {
        MetadataService.MetadataPort service = createService();
		for(Integer i=1;i<inputvalues.size();i++)        
        //for(String str : inputValues)    
        {
            MetadataService.CustomField customField = new MetadataService.CustomField();
            String[] inputvalue = inputvalues[i].split(',');            
            try{
                customField.type_x = inputvalue[1].trim();
                customField.label = inputvalue[2].trim();
                customField.fullName = inputvalue[0]+'.'+inputvalue[3].trim().replaceAll('[\\W]', '_')+'__c';
                               
                if(dataTypeContainsPrecisionField.contains(inputvalue[1].trim()))
                {
                    customField.precision= Integer.valueOf(inputvalue[4].trim());
                } else if(dataTypeContainsLengthField.contains(inputvalue[1].trim()))
                {
                    customField.length = Integer.valueOf(inputvalue[4].trim());
                }
                if(dataTypeContainsDecimalPlaceField.contains(inputvalue[1].trim()))
                {
                   customField.scale = Integer.valueOf(inputvalue[5].trim());
                } else if(dataTypeContainsVisibleLinesField.contains(inputvalue[1]))
                {
                    customField.visibleLines = Integer.valueOf(inputvalue[6].trim());
                }
                if(inputvalue[1].trim()=='Picklist' || inputvalue[1].trim()=='MultiselectPicklist')
                {
                    customField=createPicklist(customField,inputvalue);
                }
                if(!dataTypeNotContainsDefaultField.contains(inputvalue[1].trim()))
                {
                    customField.defaultValue=inputValue[9].trim();
                }
                if(! dataTypeNotContainsRequiredField.contains(inputvalue[1].trim()))
                {
                    customField.required = Boolean.valueOf(inputvalue[10].trim()); //inputvalue[10].trim().equals('TRUE');
                }
                if( dataTypeContainsUniqueField.contains(inputvalue[1].trim()))
                {
                    customField.unique = Boolean.valueOf(inputvalue[12].trim()); //inputvalue[12].trim().equals('TRUE');
                }
                if( dataTypeContainsExternalIDField.contains(inputvalue[1].trim()))
                {
                    customField.unique = Boolean.valueOf(inputvalue[13].trim()); //inputvalue[13].trim().equals('TRUE');
                }
                customField.description=inputValue[14];
                customField.inlineHelpText=inputValue[15];
                results = service.createMetadata(new MetadataService.Metadata[] { customField });
                handleSaveResults(results[0]);
                System.debug(''+results[0]);
            }
            catch(Exception e)
            {
                CSVReader.errorFieldList.put(inputvalue[2],e);
                System.debug('Error Message:'+e);
            }        
        }    
    }
    
    public static MetadataService.CustomField createPicklist( MetadataService.CustomField customField, String[] inputvalue)
    {
        if(inputValue != null && !inputValue.isEmpty() && inputValue.size()>7) {
            
        }
        String[] picklistValue=inputvalue[7].split(';');
        System.debug('picklistValue:'+picklistValue+inputvalue[7]);
        Metadataservice.Picklist pt = new Metadataservice.Picklist();
        pt.sorted= Boolean.valueOf(inputvalue[8].trim());
        List<MetadataService.PicklistValue> pickValues=new List<MetadataService.PicklistValue>();
        System.debug(picklistValue.size());
        for(Integer c=0; c<picklistValue.size();c++)
        {
             metadataservice.PicklistValue pv = new metadataservice.PicklistValue();                   
             pv.fullName = picklistValue[c];
             System.debug('1:'+picklistValue[c]+pv.fullName);
             pv.default_x=false ;
             System.debug(pv);
             pickValues.add(pv);
         }
         System.debug(pickValues);
         pt.picklistValues = pickValues;
         customField.picklist = pt ;
         return customField;        
    }
    
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
        {
            CSVReader.successFieldList.add(saveResult.fullName);
            return;
        }   
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();               
            for(MetadataService.Error error : saveResult.errors)
                messages.add(error.message);
            if(messages.size()>0)
            {
                throw new MetadataExampleFieldCreationException(String.join(messages, ' '));
                //errorFieldList.put(saveResult.fullName, new MetadataExampleFieldCreationException(String.join(messages, ' ')));
            }               
        }
        else{
            if(!saveResult.success)
            {
                throw new MetadataExampleFieldCreationException('Request failed with no specified error.');
                //errorFieldList.put(saveResult.fullName, new MetadataExampleFieldCreationException('Request failed with no specified error.'));
            }
        }      
    }
    
    public class MetadataExampleFieldCreationException extends Exception { }
    

}