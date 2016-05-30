public class ValidateData {
    
    public static Boolean isValidationComplete1=TRUE;
    public static Boolean isValidationComplete2=TRUE;
    public static Boolean isValidationComplete3=TRUE;
    public static Boolean isValidationComplete4=TRUE;
    public static Boolean isValidationComplete5=TRUE;
    
    public static Boolean validateDataBeforeSubmit(List<DataStructure> dsList)
    {
        validateLength(dsList);
        validatePicklist(dsList);
        validateLengthAndDecimal(dsList);
        validateVisibleLines(dsList);
        validateLookUp(dsList);
        if(isValidationComplete1==FALSE || isValidationComplete2==FALSE || isValidationComplete3==FALSE || isValidationComplete4==FALSE || isValidationComplete5==FALSE)
            return false;
        return true;
    }
    
    private static void validateLength(List<DataStructure> dsList)
    {
        for(DataStructure ds: dsList)
        {
            if(ds.dataTypeContainsLengthField.contains(ds.fieldType) && !ds.dataTypeContainsLengthField_NUMBER.contains(ds.fieldType))
            {
                
                if(ds.length=='' || ds.length==null)
                {
                    isValidationComplete1=FALSE;
                    ds.errorMap.put(8,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter length-> '+ds.fieldLabel)); 
                }
                else if(!ds.length.isNumeric())
                {
                    isValidationComplete1=FALSE;
                    ds.errorMap.put(8,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter valid value for length-> '+ds.fieldLabel)); 
                }
                
                
                else
                {
                    if(ds.fieldType=='Text')    
                    {System.debug('---Text'+ds.fieldType);
                     if(integer.valueOf(ds.length)>ApexLimitConstants.maxTextLength)
                     {
                         System.debug('abc');
                         ds.errorMap.put(8,true);
                         isValidationComplete1=FALSE;
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be less than or equal to '+ApexLimitConstants.maxTextLength+'->'+ds.fieldLabel)); 
                     }
                     else if(integer.valueOf(ds.length)<=ApexLimitConstants.minLength)
                     {
                         isValidationComplete1=FALSE;
                         ds.errorMap.put(8,true);
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be greater than 0-> '+ds.fieldLabel)); 
                     }
                    }
                    else if(ds.fieldType=='LongTextArea' || ds.fieldType=='Html')
                    {
                        if(integer.valueOf(ds.length)<=ApexLimitConstants.minLength)
                        {
                            isValidationComplete1=FALSE;
                            ds.errorMap.put(8,true);
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be greater than 0-> '+ds.fieldLabel)); 
                        }
                        else if(ds.fieldType=='LongTextArea')
                        {
                            if(integer.valueOf(ds.length)>ApexLimitConstants.maxLongTextAreaLength)
                            {
                                isValidationComplete1=FALSE;
                                ds.errorMap.put(8,true);
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be less than or equal to '+ApexLimitConstants.maxLongTextAreaLength+'->'+ds.fieldLabel)); 
                            }
                        }
                        else if(ds.fieldType=='Html')
                        {
                            if(integer.valueOf(ds.length)>ApexLimitConstants.maxRichTextAreaLength)
                            {
                                isValidationComplete1=FALSE;
                                ds.errorMap.put(8,true);
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be less than or equal to '+ApexLimitConstants.maxRichTextAreaLength+'->'+ds.fieldLabel)); 
                            }
                        }
                    }
                }
            }        
        }
    }
    
    
    
    private static void validatePicklist(List<DataStructure> dsList)
    {
        for(DataStructure ds: dsList)
        {
            if(ds.fieldType=='Picklist')
            {
                if(ds.picklistValue=='' || ds.picklistValue==null)
                {
                    isValidationComplete2=FALSE;
                    ds.errorMap.put(11,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter picklist values-> '+ds.fieldLabel));
                }
            }
        }
    }
    
    
    private static void validateLengthAndDecimal(List<DataStructure> dsList)
    {
        for(DataStructure ds: dsList)
        {
            if(ds.dataTypeContainsLengthField_NUMBER.contains(ds.fieldType))
            {
                if(ds.length=='' || ds.length==null)
                {
                    isValidationComplete5=FALSE;
                    ds.errorMap.put(8,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter length-> '+ds.fieldLabel)); 
                }
                else if(!ds.length.isNumeric())
                {
                    isValidationComplete5=FALSE;
                    ds.errorMap.put(8,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter valid value for length-> '+ds.fieldLabel)); 
                }
                if(ds.decimalPlace=='' || ds.decimalPlace==null)
                {
                    isValidationComplete5=FALSE;
                    ds.errorMap.put(9,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter decimal value-> '+ds.fieldLabel)); 
                }
                else if(!ds.decimalPlace.isNumeric())
                {
                    isValidationComplete5=FALSE;
                    ds.errorMap.put(9,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter valid value for decimal place-> '+ds.fieldLabel)); 
                }
                else if(((ds.length!='' || ds.length!=null) && ds.length.isNumeric())&&(ds.decimalPlace!='' || ds.decimalPlace!=null) && ds.decimalPlace.isNumeric())
                {
                    if((integer.valueof(ds.length)>ApexLimitConstants.maxNumberLength || integer.valueof(ds.decimalPlace)>ApexLimitConstants.maxNumberLength))
                    {
                        isValidationComplete5=FALSE;
                        ds.errorMap.put(8,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be less than or equal to 18-> '+ds.fieldLabel));
                    }
                    else if((integer.valueof(ds.length)<=ApexLimitConstants.minLength || integer.valueof(ds.decimalPlace)<ApexLimitConstants.minLength))
                    {
                        isValidationComplete5=FALSE;
                        ds.errorMap.put(8,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Length must be an integer greater than 0-> '+ds.fieldLabel));
                    }
                    if(((integer.valueof(ds.length) + integer.valueOf(ds.decimalPlace))>ApexLimitConstants.maxNumberLength))
                    {
                        isValidationComplete5=FALSE;
                        ds.errorMap.put(8,true);
                        ds.errorMap.put(9,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The sum of the length and decimal places must be an integer less than or equal to 18-> '+ds.fieldLabel));
                    }
                }
            }
        }
    }
    
    
    
    
    private static void validateVisibleLines(List<DataStructure> dsList)
    {
        for(DataStructure ds: dsList)
        {
            if(ds.dataTypeContainsVisibleLinesField.contains(ds.fieldType))
            {
                if((ds.visibleLines=='' || ds.visibleLines==null))
                {
                    isValidationComplete3=FALSE;
                    ds.errorMap.put(10,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the number of visible lines-> '+ds.fieldLabel)); 
                }
                
                else if(!ds.visibleLines.isNumeric())
                {
                    isValidationComplete3=FALSE;
                    ds.errorMap.put(10,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter numeric value for visible lines-> '+ds.fieldLabel)); 
                }
                else if(ds.fieldType=='MultiselectPicklist')
                {
                    if(integer.valueof(ds.visibleLines)>ApexLimitConstants.maxVisibleLinesMultiSelectPicklist)
                    {
                        isValidationComplete3=FALSE;
                        ds.errorMap.put(10,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Number of visible lines must be less than or equal to '+ApexLimitConstants.maxVisibleLinesMultiSelectPicklist +'->'+ds.fieldLabel));
                    }
                    else if(integer.valueof(ds.visibleLines)<ApexLimitConstants.minVisibleLinesMultiSelectPicklist)
                    {
                        isValidationComplete3=FALSE;
                        ds.errorMap.put(10,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Number of visible lines must be greater than or equal to '+ApexLimitConstants.minVisibleLinesMultiSelectPicklist +'->'+ds.fieldLabel));
                    }
                }
                else if(ds.fieldType=='Html')
                {
                    if(integer.valueof(ds.visibleLines)>ApexLimitConstants.maxVisibleLinesRichTextArea)
                    {
                        isValidationComplete3=FALSE;
                        ds.errorMap.put(10,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Number of visible lines must be less than or equal to '+ApexLimitConstants.maxVisibleLinesRichTextArea +'->'+ds.fieldLabel));
                    }
                    else if(integer.valueof(ds.visibleLines)<ApexLimitConstants.minVisibleLinesRichTextArea)
                    {
                        isValidationComplete3=FALSE;
                        ds.errorMap.put(10,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Number of visible lines must be greater than or equal to '+ApexLimitConstants.minVisibleLinesRichTextArea +'->'+ds.fieldLabel));
                    }
                }
                else if(ds.fieldType=='LongTextArea')
                {
                    if(integer.valueof(ds.visibleLines)>ApexLimitConstants.maxVisibleLinesLongTextArea)
                    {
                        isValidationComplete3=FALSE;
                        ds.errorMap.put(10,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Number of visible lines must be less than or equal to '+ApexLimitConstants.maxVisibleLinesLongTextArea +'->'+ds.fieldLabel));
                    }
                    else if(integer.valueof(ds.visibleLines)<ApexLimitConstants.minVisibleLinesLongTextArea)
                    {
                        isValidationComplete3=FALSE;
                        ds.errorMap.put(10,true);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Number of visible lines must be greater than or equal to '+ApexLimitConstants.minVisibleLinesLongTextArea +'->'+ds.fieldLabel));
                    }
                }
            }
        }
    }
    
    private static void validateLookUp(List<DataStructure> dsList)
    {
        for(DataStructure ds: dsList)
        {
            if(ds.fieldType=='Lookup')
            {
                if(ds.relatedToObject=='' || ds.relatedToObject==null)
                {
                    isValidationComplete4=FALSE;
                    ds.errorMap.put(18,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill all the required fields for lookup type->'+ds.fieldLabel));
                }
                else if(ds.childRelationshipName=='' || ds.childRelationshipName==null)
                {
                    isValidationComplete4=FALSE;
                    ds.errorMap.put(19,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill all the required fields for lookup type->'+ds.fieldLabel));
                }
                else if(ds.relatedListLabel=='' || ds.relatedListLabel==null)
                {
                    isValidationComplete4=FALSE;
                    ds.errorMap.put(20,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill all the required fields for lookup type->'+ds.fieldLabel));
                }	   
                String str=ds.childRelationshipName.substring(0,1);
                if(str.isNumeric())
                {
                    isValidationComplete4=FALSE;
                    ds.errorMap.put(19,true);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Name must not start with number->'+ds.fieldLabel));
                }
            }
        }        
    }
    
    public static  Boolean validateConversionOfFieldType(DataStructure ds)
    {
        if(ds.fieldType=='Lookup' && ds.changedDataType!='REFERENCE')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Lookup field type can only changed to Master Details'));
            ds.isUpdatable=false;
            ds.changedDataType=ds.fieldType;
        }
        
        else if(ds.fieldType!='Lookup' && ds.changedDataType =='REFERENCE' && ds.fieldType != ds.changedDataType )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not change field type from '+ds.fieldType+' to '+ds.changedDataType));
            ds.isUpdatable=false;
            ds.changedDataType=ds.fieldType;
        }
        
        if(ds.fieldType=='REFERENCE' && ds.changedDataType!='Lookup' )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Master Details field type can only changed to Lookup'));
            ds.isUpdatable=false;
            ds.changedDataType=ds.fieldType;
        }
       
        else if( ds.fieldType != ds.changedDataType && ds.fieldType!='REFERENCE' && ds.changedDataType =='Lookup')
        {
            System.debug(''+ds.fieldType+'****'+ds.changedDataType);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not change field type from '+ds.fieldType+' to '+ds.changedDataType));
            ds.isUpdatable=false;
            ds.changedDataType=ds.fieldType;                    
        }
        
        if(ds.changedDataType=='Location')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not change to Field Type GeoLocation'));
            ds.isUpdatable=false;
            ds.changedDataType=ds.fieldType;
        }
        return true;
    }
}