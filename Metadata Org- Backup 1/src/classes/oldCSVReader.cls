public class oldCSVReader {
    
    public string nameFile{get;set;}
    public String check{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<String> sObjectToCreate=new List<String>();
    public static Map<String, Exception> errorFieldList=new Map<String, Exception>();
    public static LIST<String> successFieldList=new LIST<String>();
    
    public Pagereference ReadFile()
    {
        nameFile=contentFile.toString();
        String[] inputValues=nameFile.split('\n');
        //List<DataStructure> listDataStructure = createDataStructure(inputValues);
        MetadataExampleFieldCreation.createField(inputvalues);
        return null;
    }
    
    public class DataStructure {
       Map<String,String> headerValueMap=new Map<String,String>();
       // String 
    }

   /* public void test(String[] inputValues)
    {
        List<string> SObjectList = new List<string>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
        {
        String name = objTyp.getDescribe().getName();
        sObjectList.add(name);
        }
        
        System.debug('Object List:'+SObjectList);
        
    }*/

    public List<String> getsuccessFieldList()
    {
        if (successFieldList!= NULL)
            if (successFieldList.size() > 0)
            	return successFieldList;
        	else
            	return null;                    
        else
            return null;
    } 
    
    public Map<String, Exception> geterrorFieldList()
    {
        if (errorFieldList!= NULL)
            if (errorFieldList.size() > 0)
            	return errorFieldList;
        	else
            	return null;                    
        else
            return null;
    } 
    
}