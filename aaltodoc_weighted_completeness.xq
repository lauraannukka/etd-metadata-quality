declare option output:method "csv";
declare option output:csv "header=yes, separator=|";
declare function local:calculate-score($element as element()?) as xs:decimal {
	 
		if (
			local-name($element) eq 'title' or
			local-name($element) eq 'creator' or
			local-name($element) eq 'abstract' or
      local-name($element) eq 'subject' and ($element/@type eq 'keyword' or $element/@type eq 'helecon')     
      )
		then
			1
		else if (local-name($element) eq 'language' or local-name($element) eq 'available' or local-name($element) eq 'issued' or 
    local-name($element) eq 'rights' or local-name($element) eq 'publisher' or local-name($element) eq 'contributor' or local-name($element) eq 'file') 
    then 0.5
	
		else if (local-name($element) eq 'type' and $element/@type eq 'dcmitype') then
			0.5
		else if (local-name($element) eq 'type' and $element/@type eq 'ontasot') then
			0.5
		else if (local-name($element) eq 'identifier' and $element/@type eq 'urn') then
			0.5
		else if (local-name($element) eq 'contributor' and ($element/@type eq 'supervisor' or $element/@type eq 'advisor')) then
			0.5
		else if (local-name($element) eq 'identifier' and $element/@type eq 'uri') then
			0.5
  	else (0)
};

let $scores:=
<scores>{
  for $record in /*:exportedRecords/*:record/*:metadata/*:qualifieddc
  return
  <record>
  <id>{data($record/*:identifier[@type="uri"])}</id>
  <ontaso>{data($record/*:type[@type="ontasot" and @xml:lang="fi"])}</ontaso>
  <tallennuspvm>{data($record/*:available)}</tallennuspvm>
  <score>{round-half-to-even((sum((
  local:calculate-score($record/*:subject[@type eq 'helecon'[1] or @type eq 'keyword'[1] or not(@type)][1]),
  local:calculate-score($record/*:title[1]),
  local:calculate-score($record/*:creator[1]),
  local:calculate-score($record/*:rights[1]),
  local:calculate-score($record/*:issued[1]),
  local:calculate-score($record/*:publisher[1]),
  local:calculate-score($record/*:available[1]),
  local:calculate-score($record/*:language[1]),
  local:calculate-score($record/*:abstract[1]),
  local:calculate-score($record/*:contributor[not(@type)][1]),
  local:calculate-score($record/*:contributor[@type eq 'advisor'[1] or @type eq 'supervisor'[1]][1]),
  local:calculate-score($record/*:type[@type eq 'dcmitype'][1]),
  local:calculate-score($record/*:type[@type eq 'ontasot'][1]),
  local:calculate-score($record/*:identifier[@type eq 'urn'][1]),
  local:calculate-score($record/*:identifier[@type eq 'uri'][1]),
  local:calculate-score($record/*:file[1])
  )
  
) div 10),2)}
</score>

</record>
}</scores>

let $csv:=
  <csv>{
  for $record in $scores/record
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

