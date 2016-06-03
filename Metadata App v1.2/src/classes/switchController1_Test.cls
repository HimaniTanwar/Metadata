public class switchController1_Test {
    public static void  FetchData(){
        MetadataService.MetadataPort service = MetadataApi.createService();     
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryWorkflow = new MetadataService.ListMetadataQuery();
        queryWorkflow.type_x = 'WorkflowRule';
        queries.add(queryWorkflow);     
        MetadataService.ListMetadataQuery queryValidationRule = new MetadataService.ListMetadataQuery();
        queryValidationRule.type_x = 'ValidationRule';
        queries.add(queryValidationRule);
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.type_x = 'Layout';
        queries.add(queryLayout);           
        
        try {
            MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
            for(MetadataService.FileProperties fileProperty : fileProperties)
            {
                System.debug(fileProperty.fullName); 
                string bc = fileProperty.fullName;
                system.debug('bc = '+bc);
                list<string> abc = bc.split('.');
                for(integer i =0 ; i<abc.size();i++)
                {
                                system.debug('abc = '+abc[i]);          
                }
                system.debug('abc = '+abc);
                System.debug(fileProperty.type_x);
                System.debug(fileProperty.fileName);
            }
        } catch(exception e) { system.debug('Error : '+e);}
    }
}