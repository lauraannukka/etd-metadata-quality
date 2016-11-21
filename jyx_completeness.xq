import module namespace functx = 'http://www.functx.com';
declare option output:method "csv";
declare option output:csv "header=yes, separator=|";


declare function local:mash($elements as element()*) as xs:string {
  
  string-join($elements,'')
};

declare function local:create-clean-record($record as node()) as node() {
 
    <record>
    <id>{data($record/dc_identifier_uri)}</id>
    <dc_contributor_authors>{local:mash(($record/dc_contributor_author,$record/dc_contributor_author__))}</dc_contributor_authors>
    
    <dc_title>{local:mash(($record/dc_title,$record/dc_title__,$record/dc_title_en,$record/dc_title_enUS_,$record/dc_title_en_,$record/dc_title_fi_))}</dc_title>
    
    <dc_type_ontasot>{local:mash(($record/dc_type_ontasot_en,$record/dc_type_ontasot_en_,$record/dc_type_ontasot_fi_))}</dc_type_ontasot>
    
    <dc_language>{local:mash(($record/dc_language__,$record/dc_language_iso,$record/dc_language_iso__))}</dc_language>
    
    <dc_contributor_uni>{local:mash(($record/dc_contributor_yliopisto_fi_,$record/dc_contributor_yliopisto_en_,$record/dc_contributor_tiedekunta__,$record/dc_contributor_tiedekunta_en,$record/dc_contributor_tiedekunta_en_,$record/dc_contributor_tiedekunta_fi_,$record/dc_contributor_laitos,$record/dc_contributor_laitos__,$record/dc_contributor_laitos_en,$record/dc_contributor_laitos_en_,$record/dc_contributor_laitos_fi_))}</dc_contributor_uni>
    
    <dcmitype>{local:mash(($record/dc_type_dcmitype_en,$record/dc_type_dcmitype_en_))}</dcmitype>
    
    <dc_date_issued>{local:mash(($record/dc_date_issued,$record/dc_date_issued__,$record/dc_date_issued_fi_,$record/date_issued_en))}</dc_date_issued>
    
    <dc_identifier_urn>{local:mash(($record/dc_identifier_urn,$record/dc_identifier_urn__,$record/dc_identifier_urn_fi_))}</dc_identifier_urn>
    
    <dc_abstract>{local:mash(($record/dc_description_abstract,$record/dc_description_abstract__,$record/dc_description__,$record/dc_description_abstract_en,$record/dc_description_abstract_en_,$record/dc_description_abstract_fi_,$record/dc_description_en_))}</dc_abstract>
    
    <dc_subject>{local:mash(($record/dc_subject_kota,$record/dc_subject_kota__,$record/dc_subject_other,$record/dc_subject_other__,$record/dc_subject_other_en,$record/dc_subject_other_enUS_,$record/dc_subject_other_en_,$record/dc_subject_other_fi_,$record/dc_subject_ysa,$record/dc_subject_ysa__))}</dc_subject>
    
    <dc_tieteenala>{local:mash(($record/dc_contributor_oppiaine,$record/dc_contributor_oppiaine__,$record/dc_contributor_oppiaine_en,$record/dc_contributor_oppiaine_fi_,$record/dc_contributor_en_))}</dc_tieteenala>
    
    <dc_rights>{local:mash(($record/dc_rights__,$record/dc_rights_en,$record/dc_rights_en__,$record/dc_rights_fi))}</dc_rights>
    
    <dc_publisher>{local:mash(($record/dc_publisher,$record/dc_publisher__))}</dc_publisher>
    
    <dc_contributor_advisor>{local:mash(($record/dc_contributor_advisor,$record/dc_contributor_advisor__))}</dc_contributor_advisor>
    
    <dc_extent>{local:mash(($record/dc_format_extent,$record/dc_format_extent__,$record/dc_format_extent_enUS_,$record/dc_format_extent_fi_))}</dc_extent>
    
    <dc_url>{local:mash(($record/dc_identifier_uri,$record/dc_identifier_uri__,$record/dc_identifier_uri_en))}</dc_url>
    </record>
  
};


declare function local:calculate-elements-with-content($element_to_match as node()) as node()? {
  let $elements_to_check:=('dc_contributor_authors','dc_title','dc_language','dc_contributor_uni','dcmitype','date_issued','dc_identifier_urn','dc_abstract','dc_subject','dc_tieteenala','dc_rights','dc_publisher','dc_extent','dc_url','dc_type_ontasot', 'dc_contributor_advisor')
  let $element_name:=name($element_to_match)
  let $element_match:=
  for $name in $elements_to_check
  let $match:=$element_name[. contains text {$name}]
  return if ($match and string-length($element_to_match)>=1) then
    <element name="{$element_name}">1</element>
  else()
  
 
  
  return $element_match
  
  
};

declare function local:calculate-record-score($record as node()) as xs:double {
  let $elements_to_check:=('dc_contributor_authors','dc_title','dc_language','dc_contributor_uni','dcmitype','date_issued','dc_identifier_urn','dc_abstract','dc_subject','dc_tieteenala','dc_rights','dc_publisher','dc_extent','dc_url','dc_type_ontasot','dc_contributor_advisor')
  
  return fn:round-half-to-even(
    sum($record/element) div 17, (:16 kenttää:)
    2)
  
};


(:for $record in $testdata/metadata/metadata
for $element in $record/*
return local:calculate-elements-with-content($record
):)

let $csv :=
<csv>{
for $metadata in /csv/record
let $urn1 := $metadata/dc_identifier_urn
let $urn2 := $metadata/dc_identifier_urn__
let $urn3 := $metadata/dc_identifier_urn_fi_
let $ontaso1 := $metadata/dc_type_ontasot_en
let $ontaso2 := $metadata/dc_type_ontasot_en_
let $ontaso3 := $metadata/dc_type_ontasot_fi_



return
<record>
<score>{local:calculate-record-score(<record>{
for $element in local:create-clean-record($metadata)/*
  return local:calculate-elements-with-content($element)
}
</record>)}</score>
<id>{data(if (string-length($urn1) >= 1) then 
$urn1 else if (string-length($urn2) >= 1) then $urn2
else ($urn3))}</id>
<ontaso>{data(if(string-length($ontaso1) >= 1) then $ontaso1
else if(string-length($ontaso2) >= 1) then $ontaso2
else($ontaso3))}
</ontaso>



</record>
}</csv>

return $csv