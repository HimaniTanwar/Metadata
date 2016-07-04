public class CSVReaderHelperClass {
    private List<DataStructure> dsList=new LIST<DataStructure>();
    Set<String> profileSet=new Set<String>();
    
    public List<DataStructure> createStructure(String[] inputvalues){
        createDataStructure(inputvalues);
        createStructureForFLS(this.dsList);
        createStructureForLayoutAssignment(this.dsList);
        return dsList;
        
    }
    public void createDataStructure(String[] inputvalues)
    {
        System.debug('Inside createDataStructure');
        dsList.clear();
        for(Integer i=1;i<inputValues.size();i++)
        {
            String[] inputvalue=inputValues[i].split(',');      //Spliting Each Coloumn of CSV data
            if(inputvalue[0]!='' && inputvalue[1]!='' && inputvalue[2]!='')   
            {
                System.debug('@@@'+inputvalue);
                DataStructure ds=new DataStructure();                
                ds.objectName=inputvalue[0].trim();
                ds.fieldType=inputvalue[1].trim();
                ds.changedDataType=ds.fieldType;
                ds.fieldLabel=inputvalue[2].trim();
                if(ds.fieldLabel!=null){
                    getCorrectFieldName(ds, inputvalue);
                } 
                if(ds.dataTypeContainsLengthField.contains(ds.fieldType)){
                    if(inputvalue[4].trim()!=null && inputvalue[4].trim()!='')
                        ds.length=inputvalue[4].trim();
                    else
                        ds.length='0';
                }
                if(ds.dataTypeContainsDecimalPlaceField.contains(ds.fieldType)){
                    if(inputvalue[5].trim()!=null && inputvalue[5].trim()!='')
                        ds.decimalPlace=(inputvalue[5].trim());
                    else
                        ds.decimalPlace='0';    
                }
                if(ds.dataTypeContainsVisibleLinesField.contains(ds.fieldType)){
                    if(inputvalue[6].trim()!=null && inputvalue[6].trim()!='')
                        ds.visibleLines=(inputvalue[6].trim());
                    else
                        ds.visibleLines='0';
                }
                if(ds.fieldType=='Picklist'||ds.fieldType=='MultiselectPicklist'){
                    if(inputvalue[7].trim()!=null && inputvalue[7].trim()!=''){
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
                if(ds.dataTypeContainsDefaultField.contains(ds.fieldType)){
                    if(inputvalue[9].trim()!=null && inputvalue[9].trim()!='')
                        ds.fieldDefaultValue=inputvalue[9].trim();
                    if(ds.fieldType=='Checkbox')
                        ds.fieldDefaultValue=String.valueOf(false);
                    else
                        ds.fieldDefaultValue='';                
                }            
                if(ds.dataTypeContainsRequiredField.contains(ds.fieldType)){
                    if(inputvalue[10].trim()!=null && inputvalue[10].trim()!='')
                        ds.required=Boolean.valueOf(inputvalue[10].trim());
                    
                    ds.requiredCheck='';
                }
                if(inputvalue[11].trim()!=null && inputvalue[11].trim()!='')
                    ds.trackFeedHistory=Boolean.valueOf(inputvalue[11].trim());
                
                if(ds.dataTypeContainsUniqueField.contains(ds.fieldType)){
                    if(inputvalue[12].trim()!=null && inputvalue[12].trim()!='')
                        ds.unique=Boolean.valueOf(inputvalue[12].trim());
                    
                    ds.uniqueCheck='';
                }
                
                if(ds.dataTypeContainsExternalIDField.contains(ds.fieldType)){
                    if(inputvalue[13].trim()!=null && inputvalue[13].trim()!='')
                        ds.externalId=Boolean.valueOf(inputvalue[13].trim());
                    
                    ds.externalIdCheck='';
                }
                if(ds.fieldType=='Lookup'){
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
    
    private void getCorrectFieldName(DataStructure ds, String[] inputvalue){
        ds.fieldName=inputvalue[2].replaceAll('\\s+', ' ').trim().replaceAll('[\\W]', '_');//+'__c';
        
        String firstCharacter=ds.fieldName.substring(0,1);
        if(firstCharacter.isNumeric()){
            ds.fieldName='X' + ds.fieldName;
        }
        ds.fieldName=ds.fieldName.replaceAll('\\_+', '_');
        Integer fieldNameLength=ds.fieldName.length();
        String lastCharacter=ds.fieldName.substring(fieldNameLength-1, fieldNameLength);
        ds.fieldName=ds.fieldName+'__c';
        if(lastCharacter=='_'){
            ds.fieldName=ds.fieldName.replaceAll('__','_');
        }
    }
    
    public void createStructureForFLS(List<DataStructure> dsList){
        profileSet=MetadataApi.fetchAllProfile();
        if(profileSet.size()> 0 && !profileSet.isEmpty()){
            for(DataStructure ds: dsList){
                ds.allOptionsForReadOnly=new List<SelectOption>();
                ds.allOptionsForVisibleOnly=new List<SelectOption>();
                for(String str:profileSet){
                    String displayProfileName;
                    if(str.contains('%2E'))
                        displayProfileName=str.replaceAll('%2E','.');
                    
                    else if(str.contains('%3A'))
                        displayProfileName=str.replaceAll('%3A',':');
                    else
                        displayProfileName=str;
                    ds.allOptionsForReadOnly.add(new SelectOption(str,displayProfileName));
                    ds.allOptionsForVisibleOnly.add(new SelectOption(str,displayProfileName));
					                   
                }
            }
        }       
    }
    
    public List<DataStructure> createStructureForLayoutAssignment(List<DataStructure> dsList){
        Map<String, List<String>> objectLayoutMap=new  Map<String, List<String>>();
        objectLayoutMap=MetadataApi.fetchAllLayouts();
        for(DataStructure ds:dsList){
            ds.allOptionsForLayoutAssignment = new List<SelectOption>();
            Set<String> tempSetOfselectedOptionsForLayoutAssignment=new Set<String>();
            
            if(ds.selectedOptionsForLayoutAssignment!=null && ds.selectedOptionsForLayoutAssignment.size()>0){
                for(SelectOption so:ds.selectedOptionsForLayoutAssignment)
                    tempSetOfselectedOptionsForLayoutAssignment.add(so.getValue());
            }
            if(objectLayoutMap.containsKey(ds.objectName)){
                for(String str:(objectLayoutMap.get(ds.objectName))){
                    String displayLayou=str.replaceAll('%28','(');
                    displayLayou=displayLayou.replaceAll('%29',')');
                    if(!tempSetOfselectedOptionsForLayoutAssignment.contains(str))
                        ds.allOptionsForLayoutAssignment.add(new SelectOption(str,displayLayou));       
                }
            }
        }
        return dsList;
    }
   
}