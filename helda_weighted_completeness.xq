import module namespace functx = 'http://www.functx.com';
declare option output:method "csv";
declare option output:csv "header=yes, separator=|";

declare function local:calculate-score($element as element()?) as xs:decimal {
	 
		if ((
			local-name($element) eq 'creator' or
			local-name($element) eq 'title' or
			local-name($element) eq 'description' or
			local-name($element) eq 'subject' and $element[not(functx:has-empty-content(.))] )
    )
		then
			1
    else if ((local-name($element) eq 'language' or local-name($element) eq 'date' or local-name($element) eq 'contributor' or local-name($element) eq 'rights' or local-name($element) eq 'publisher' or local-name($element) eq 'format' and $element[not(functx:has-empty-content(.))] )) then
    0.5
		else if (local-name($element) eq 'ohjaaja' and $element[not(functx:has-empty-content(.))]) 	then 
      0.5
    else if (local-name($element) eq 'dcmitype' and $element[not(functx:has-empty-content(.))])	then
			0.5
    else if (local-name($element) eq 'ontaso' and $element[not(functx:has-empty-content(.))])	then
			0.5 
    else if (local-name($element) eq 'identifier' and contains($element,"URN") and $element[not(functx:has-empty-content(.))]) then
			0.5
		else if (local-name($element) eq 'identifier' and contains($element,"http") and $element[not(functx:has-empty-content(.))]) then
			0.5  
  	else (0)
};

declare function local:check-if-dcmitype($element as element()?) as xs:decimal {

			if (local-name($element) eq 'type' and $element contains text {'text', 'Text'} any )	then
			0.5   
  	else (0)
};

let $scores:=
<scores>{
  for $record in /exportedRecords/record/metadata/RDF/Publication
  let $ohjaaja:=<ohjaaja>{concat($record/ths[1],$record/opn[1])}</ohjaaja>
  let $types:=
    <types>{
    for $type in $record/type
      return if (local:check-if-dcmitype($type)) then
      element {'dcmitype'} {'dcmitype'}
      else (element {'ontaso'} {'ontaso'})
   }</types> 
   
   let $distinct_types:=for $type in distinct-values($types/*)
     return  element {$type} {$type}
  
  
  return
  <record>
  <id>{data($record/identifier[1])}</id>
  <ontaso>{data($record/type[1])}</ontaso>
  <tallennuspvm>{data($record/date[1])}</tallennuspvm>
  
  <score>{round-half-to-even((sum((
  local:calculate-score($record/creator[1]),
  local:calculate-score($record/title[1]),
  local:calculate-score($record/language[1]),
  local:calculate-score($record/date[1]),
  local:calculate-score($record/contributor[1]),
  local:calculate-score($record/description[1]),
  local:calculate-score($record/subject[1]),
  local:calculate-score($record/rights[1]),
  local:calculate-score($record/publisher[1]),
  local:calculate-score($record/format[1]),
  local:calculate-score($ohjaaja),
  local:calculate-score($distinct_types[1]),
  local:calculate-score($distinct_types[2]),
  local:calculate-score($record/identifier[contains(.,"URN")][1]),
  local:calculate-score($record/identifier[contains(.,"http")][1])
  )) div 10),2)}
</score>
</record>}
</scores>
let $csv :=
<csv>{
  for $record in $scores//record
  let $quality := $record/score 
  let $id := $record/id
  let $ontaso := $record/ontaso
  let $tallennus := substring-before($record/tallennuspvm,"-")
  order by $quality

return 

  <record>
    <score>{data($quality)}</score>
    <id>{data($id)}</id>
    <ontaso>{data($ontaso)}</ontaso>
    <tallennuspvm>{data($tallennus)}</tallennuspvm>
    
  </record>
}</csv>
return $csv
