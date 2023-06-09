##!/bin/bash
echo -e "

 ██████ ██    ██ ███████       ███████ ███████ ████████  ██████ ██   ██ ███████ ██████
██      ██    ██ ██            ██      ██         ██    ██      ██   ██ ██      ██   ██
██      ██    ██ █████   █████ █████   █████      ██    ██      ███████ █████   ██████
██       ██  ██  ██            ██      ██         ██    ██      ██   ██ ██      ██   ██
 ██████   ████   ███████       ██      ███████    ██     ██████ ██   ██ ███████ ██   ██

"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <CVE-ID>"
  exit 1
fi

CVE_ID=$1

# Fetch CVE information using NVD API
CVE_DATA=$(curl -s "https://services.nvd.nist.gov/rest/json/cve/1.0/$CVE_ID")

# Extract relevant information using 'jq'
CVE_TITLE=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].cve.description.description_data[0].value')
AFFECTED_PRODUCTS=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].configurations.nodes[].cpe_match[] | "\(.cpe23Uri) version: \(.versionEndIncluding)"')
SEVERITY=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].impact.baseMetricV3.cvssV3.baseSeverity')
BASE_SCORE=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].impact.baseMetricV3.cvssV3.baseScore')
EXPLOITABILITY_SCORE=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].impact.baseMetricV3.exploitabilityScore')
IMPACT_SCORE=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].impact.baseMetricV3.impactScore')
PUBLISHED_DATE=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].publishedDate')
LAST_MODIFIED_DATE=$(echo "$CVE_DATA" | jq -r '.result.CVE_Items[0].lastModifiedDate')

# Print the results
echo -e "\e[92mCVE ID:\e[0m\n$CVE_ID"
echo -e "\e[92mCVE Title:\e[0m\n$CVE_TITLE"
echo -e "\e[92mAffected Products and Versions:\e[0m"
echo "$AFFECTED_PRODUCTS"
echo -e "\e[92mSeverity:\e[0m\n$SEVERITY"
echo -e "\e[92mBase Score:\e[0m\n$BASE_SCORE"
echo -e "\e[92mExploitability Score:\e[0m\n$EXPLOITABILITY_SCORE"
echo -e "\e[92mImpact Score:\e[0m\n$IMPACT_SCORE"
echo -e "\e[92mPublished Date:\e[0m\n$PUBLISHED_DATE"
echo -e "\e[92mLast Modified Date:\e[0m\n$LAST_MODIFIED_DATE"
# Finding Exploits
data=$(curl -s -X GET https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=$CVE_ID)
if echo $data | grep -q 'Exploit"'; then
  exploit_urls=$(echo $data | jq -r '.vulnerabilities[].cve.references[] | select(.tags[] | contains("Exploit")) | .url' 2>/dev/null)
  if [ -z "$exploit_urls" ]; then
    echo -e "\e[92mNo exploit links found.\e[0m"
  else
    echo -e "\e[92mExploit links:\e[0m"
    IFS=$'\n'
    counter=1
    for url in $exploit_urls; do
      echo "[$counter] $url"
      counter=$((counter + 1))
    done
  fi
else
  echo -e "\e[92mNo exploit links found.\e[0m"
fi
