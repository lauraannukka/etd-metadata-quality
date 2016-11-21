import module namespace functx = 'http://www.functx.com';
declare option output:method "csv";
declare option output:csv "header=yes, separator=|";

declare function local:calculate-score($element as element()?) as xs:integer {
	 
		if ((
			local-name($element) eq 'title' or
			local-name($element) eq 'creator' or
			local-name($element) eq 'type' or
			local-name($element) eq 'date.created' or
			local-name($element) eq 'subject' or
			local-name($element) eq 'rights' or
      local-name($element) eq 'publisher') and $element[not(functx:has-empty-content(.))] )
		then
			1
     else if (local-name($element) eq 'identifier' and not(contains($element,'campus_use'))) then
      1
     else if (local-name($element) eq 'identifier' and contains($element,'campus_use')) then
      0	   
  	else (0)
};
declare function local:calculate-score-plain-identifier($element as element()?) as xs:numeric {
	 

			if (local-name($element) eq 'identifier') then
      1
   
  	else (0)
};

let $scores:=
<scores>{
  for $record in /exportedRecords/record/metadata/dc
  
  return
  <record>
  <id>{data($record/identifier)}</id>
  <tallennuspvm>{data($record/date.created)}</tallennuspvm>
  
  <score>{round-half-to-even((sum((
  local:calculate-score($record/subject[1]),
  local:calculate-score($record/title[1]),
  local:calculate-score($record/creator[1]),
  local:calculate-score($record/rights[1]),
  local:calculate-score($record/publisher[1]),
  local:calculate-score($record/type[1]),
  local:calculate-score($record/identifier[1]),
  local:calculate-score-plain-identifier($record/identifier[1]),
  local:calculate-score($record/date.created[1])
  )
  
) div 16),2)}
</score>
</record>
}</scores>

let $csv :=
<csv>{

for $record in $scores/record
let $quality := $record/score 
let $id := $record/id
let $tallennus := substring-before($record/tallennuspvm,"-")
order by $quality

return 

<record>

<score>{data($quality)}</score>
<id>{data($id)}</id>
<tallennuspvm>{data($tallennus)}</tallennuspvm>
</record>

}</csv>
return $csv

