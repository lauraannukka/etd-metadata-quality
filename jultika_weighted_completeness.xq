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
    else if(local-name($element) eq 'language' or local-name($element) eq 'date' or local-name($element) eq 'type' or local-name($element) eq 'rights' or local-name($element) eq 'publisher' or local-name($element) eq 'format'  or local-name($element) eq 'contributor'
    )
    then
    0.5
    else if (local-name($element) eq 'identifier' and contains($element,"urn") and $element[not(functx:has-empty-content(.))]) then
		0.5
		else if (local-name($element) eq 'identifier' and contains($element,"http") and $element[not(functx:has-empty-content(.))]) then
		0.5  
  	else (0)
};

let $scores:=
<scores>{
  for $record in /records/Record/metadata/dc
   
  return
  <record>  
  <id>{data($record/identifier[1])}</id>
  <ontaso>{data($record/type[1])}</ontaso>
  <tallennuspvm>{data($record/date[1])}</tallennuspvm>
  
  <score>{round-half-to-even((sum((
  local:calculate-score($record/creator[1]),
  local:calculate-score($record/title[1]),
  local:calculate-score($record/type[1]),
  local:calculate-score($record/language[1]),
  local:calculate-score($record/date[1]),
  local:calculate-score($record/description[1]),
  local:calculate-score($record/subject[1]),
  local:calculate-score($record/rights[1]),
  local:calculate-score($record/publisher[1]),
  local:calculate-score($record/format[1]),
  local:calculate-score($record/contributor[1]),
  local:calculate-score($record/identifier[contains(.,"urn")][1]),
  local:calculate-score($record/identifier[contains(.,"http")][1])
  )) div 11),2)}
</score>
</record>}
</scores>
let $csv :=
<csv>{
  for $record in $scores//record
  let $quality := $record/score 
  let $id := $record/id
  let $ontaso := substring-after($record/ontaso,'semantics/')
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

