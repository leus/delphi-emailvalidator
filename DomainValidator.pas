unit DomainValidator;

interface

uses RegularExpressions, Generics.Collections;

// Regular expression strings for hostnames (derived from RFC2396 and RFC 1123)
const
  DOMAIN_LABEL_REGEX = '[[:alnum:]](?>[[:alnum:]-]*[[:alnum:]])*';
  TOP_LABEL_REGEX = '[[:alnum:]]{2,}';
  DOMAIN_NAME_REGEX = '^(?:' + DOMAIN_LABEL_REGEX + '\.)+' + '(' +
    TOP_LABEL_REGEX + ')$';

type

  TDomainValidator = class
  private
    allowLocal: boolean;
    domainRegex, hostnameRegex: TRegEx;
    function chompLeadingDot(str: String): String;
  public
    function isValid(domain: String): boolean;
    function isValidTld(tld: String): boolean;
    function isValidInfrastructureTld(iTld: String): boolean;
    function isValidLocalTld(iTld: String): boolean;
    function isValidGenericTld(gTld: String): boolean;
    function isValidCountryCodeTld(ccTld: String): boolean;
    constructor Create(allowLocal: boolean = false);
  end;

var
  INFRASTRUCTURE_TLD_LIST, GENERIC_TLD_LIST, COUNTRY_CODE_TLD_LIST,
    LOCAL_TLD_LIST: TList<String>;

implementation

uses SysUtils, StrUtils;

{ TDomainValidator }

function TDomainValidator.chompLeadingDot(str: String): String;
begin
  if AnsiStartsStr('.', str) then
    Result := Copy(str, 1, Length(str) - 1)
  else
    Result := str;
end;

constructor TDomainValidator.Create(allowLocal: boolean);
begin
  Self.allowLocal := allowLocal;
  domainRegex := TRegEx.Create(DOMAIN_NAME_REGEX, [roCompiled]);
  hostnameRegex := TRegEx.Create(DOMAIN_LABEL_REGEX, [roCompiled]);
end;

function TDomainValidator.isValid(domain: String): boolean;
var
  Match: TMatch;
begin
  Result := false;
  Match := domainRegex.Match(domain);
  if Match.Success and (Match.Groups.Count > 0) then
    Result := isValidTld(Match.Groups[1].Value)
  else
  begin
    if allowLocal then
      Result := hostnameRegex.IsMatch(domain);
  end;
end;

function TDomainValidator.isValidCountryCodeTld(ccTld: String): boolean;
begin
  Result := COUNTRY_CODE_TLD_LIST.contains
    (chompLeadingDot(AnsiLowerCase(ccTld)));
end;

function TDomainValidator.isValidGenericTld(gTld: String): boolean;
begin
  Result := GENERIC_TLD_LIST.contains(chompLeadingDot(AnsiLowerCase(gTld)));
end;

function TDomainValidator.isValidInfrastructureTld(iTld: String): boolean;
begin
  Result := INFRASTRUCTURE_TLD_LIST.contains
    (chompLeadingDot(AnsiLowerCase(iTld)));

end;

function TDomainValidator.isValidLocalTld(iTld: String): boolean;
begin
  Result := LOCAL_TLD_LIST.contains(chompLeadingDot(AnsiLowerCase(iTld)));

end;

function TDomainValidator.isValidTld(tld: String): boolean;
begin
  if allowLocal and isValidLocalTld(tld) then
    Result := True
  else
    Result := isValidInfrastructureTld(tld) or isValidGenericTld(tld) or
      isValidCountryCodeTld(tld);
end;

initialization

INFRASTRUCTURE_TLD_LIST := TList<String>.Create;
INFRASTRUCTURE_TLD_LIST.AddRange(['arpa', // internet infrastructure
  'root' // diagnostic marker for non-truncated root zone
  ]);

GENERIC_TLD_LIST := TList<String>.Create;
GENERIC_TLD_LIST.AddRange(['aero', // air transport industry
  'asia', // Pan-Asia/Asia Pacific
  'biz', // businesses
  'cat', // Catalan linguistic/cultural community
  'com', // commercial enterprises
  'coop', // cooperative associations
  'info', // informational sites
  'jobs', // Human Resource managers
  'mobi', // mobile products and services
  'museum', // museums, surprisingly enough
  'name', // individuals' sites
  'net', // internet support infrastructure/business
  'org', // noncommercial organizations
  'pro', // credentialed professionals and entities
  'tel', // contact data for businesses and individuals
  'travel', // entities in the travel industry
  'gov', // United States Government
  'edu', // accredited postsecondary US education entities
  'mil', // United States Military
  'int' // organizations established by international treaty
  ]);

COUNTRY_CODE_TLD_LIST := TList<String>.Create;
COUNTRY_CODE_TLD_LIST.AddRange(['ac', // Ascension Island
  'ad', // Andorra
  'ae', // United Arab Emirates
  'af', // Afghanistan
  'ag', // Antigua and Barbuda
  'ai', // Anguilla
  'al', // Albania
  'am', // Armenia
  'an', // Netherlands Antilles
  'ao', // Angola
  'aq', // Antarctica
  'ar', // Argentina
  'as', // American Samoa
  'at', // Austria
  'au', // Australia (includes Ashmore and Cartier Islands and Coral Sea Islands)
  'aw', // Aruba
  'ax', // �?land
  'az', // Azerbaijan
  'ba', // Bosnia and Herzegovina
  'bb', // Barbados
  'bd', // Bangladesh
  'be', // Belgium
  'bf', // Burkina Faso
  'bg', // Bulgaria
  'bh', // Bahrain
  'bi', // Burundi
  'bj', // Benin
  'bm', // Bermuda
  'bn', // Brunei Darussalam
  'bo', // Bolivia
  'br', // Brazil
  'bs', // Bahamas
  'bt', // Bhutan
  'bv', // Bouvet Island
  'bw', // Botswana
  'by', // Belarus
  'bz', // Belize
  'ca', // Canada
  'cc', // Cocos (Keeling) Islands
  'cd', // Democratic Republic of the Congo (formerly Zaire)
  'cf', // Central African Republic
  'cg', // Republic of the Congo
  'ch', // Switzerland
  'ci', // Côte d'Ivoire
  'ck', // Cook Islands
  'cl', // Chile
  'cm', // Cameroon
  'cn', // China, mainland
  'co', // Colombia
  'cr', // Costa Rica
  'cu', // Cuba
  'cv', // Cape Verde
  'cx', // Christmas Island
  'cy', // Cyprus
  'cz', // Czech Republic
  'de', // Germany
  'dj', // Djibouti
  'dk', // Denmark
  'dm', // Dominica
  'do', // Dominican Republic
  'dz', // Algeria
  'ec', // Ecuador
  'ee', // Estonia
  'eg', // Egypt
  'er', // Eritrea
  'es', // Spain
  'et', // Ethiopia
  'eu', // European Union
  'fi', // Finland
  'fj', // Fiji
  'fk', // Falkland Islands
  'fm', // Federated States of Micronesia
  'fo', // Faroe Islands
  'fr', // France
  'ga', // Gabon
  'gb', // Great Britain (United Kingdom)
  'gd', // Grenada
  'ge', // Georgia
  'gf', // French Guiana
  'gg', // Guernsey
  'gh', // Ghana
  'gi', // Gibraltar
  'gl', // Greenland
  'gm', // The Gambia
  'gn', // Guinea
  'gp', // Guadeloupe
  'gq', // Equatorial Guinea
  'gr', // Greece
  'gs', // South Georgia and the South Sandwich Islands
  'gt', // Guatemala
  'gu', // Guam
  'gw', // Guinea-Bissau
  'gy', // Guyana
  'hk', // Hong Kong
  'hm', // Heard Island and McDonald Islands
  'hn', // Honduras
  'hr', // Croatia (Hrvatska)
  'ht', // Haiti
  'hu', // Hungary
  'id', // Indonesia
  'ie', // Ireland (�?ire)
  'il', // Israel
  'im', // Isle of Man
  'in', // India
  'io', // British Indian Ocean Territory
  'iq', // Iraq
  'ir', // Iran
  'is', // Iceland
  'it', // Italy
  'je', // Jersey
  'jm', // Jamaica
  'jo', // Jordan
  'jp', // Japan
  'ke', // Kenya
  'kg', // Kyrgyzstan
  'kh', // Cambodia (Khmer)
  'ki', // Kiribati
  'km', // Comoros
  'kn', // Saint Kitts and Nevis
  'kp', // North Korea
  'kr', // South Korea
  'kw', // Kuwait
  'ky', // Cayman Islands
  'kz', // Kazakhstan
  'la', // Laos (currently being marketed as the official domain for Los Angeles)
  'lb', // Lebanon
  'lc', // Saint Lucia
  'li', // Liechtenstein
  'lk', // Sri Lanka
  'lr', // Liberia
  'ls', // Lesotho
  'lt', // Lithuania
  'lu', // Luxembourg
  'lv', // Latvia
  'ly', // Libya
  'ma', // Morocco
  'mc', // Monaco
  'md', // Moldova
  'me', // Montenegro
  'mg', // Madagascar
  'mh', // Marshall Islands
  'mk', // Republic of Macedonia
  'ml', // Mali
  'mm', // Myanmar
  'mn', // Mongolia
  'mo', // Macau
  'mp', // Northern Mariana Islands
  'mq', // Martinique
  'mr', // Mauritania
  'ms', // Montserrat
  'mt', // Malta
  'mu', // Mauritius
  'mv', // Maldives
  'mw', // Malawi
  'mx', // Mexico
  'my', // Malaysia
  'mz', // Mozambique
  'na', // Namibia
  'nc', // New Caledonia
  'ne', // Niger
  'nf', // Norfolk Island
  'ng', // Nigeria
  'ni', // Nicaragua
  'nl', // Netherlands
  'no', // Norway
  'np', // Nepal
  'nr', // Nauru
  'nu', // Niue
  'nz', // New Zealand
  'om', // Oman
  'pa', // Panama
  'pe', // Peru
  'pf', // French Polynesia With Clipperton Island
  'pg', // Papua New Guinea
  'ph', // Philippines
  'pk', // Pakistan
  'pl', // Poland
  'pm', // Saint-Pierre and Miquelon
  'pn', // Pitcairn Islands
  'pr', // Puerto Rico
  'ps', // Palestinian territories (PA-controlled West Bank and Gaza Strip)
  'pt', // Portugal
  'pw', // Palau
  'py', // Paraguay
  'qa', // Qatar
  're', // Réunion
  'ro', // Romania
  'rs', // Serbia
  'ru', // Russia
  'rw', // Rwanda
  'sa', // Saudi Arabia
  'sb', // Solomon Islands
  'sc', // Seychelles
  'sd', // Sudan
  'se', // Sweden
  'sg', // Singapore
  'sh', // Saint Helena
  'si', // Slovenia
  'sj', // Svalbard and Jan Mayen Islands Not in use (Norwegian dependencies; see .no)
  'sk', // Slovakia
  'sl', // Sierra Leone
  'sm', // San Marino
  'sn', // Senegal
  'so', // Somalia
  'sr', // Suriname
  'st', // São Tomé and Príncipe
  'su', // Soviet Union (deprecated)
  'sv', // El Salvador
  'sy', // Syria
  'sz', // Swaziland
  'tc', // Turks and Caicos Islands
  'td', // Chad
  'tf', // French Southern and Antarctic Lands
  'tg', // Togo
  'th', // Thailand
  'tj', // Tajikistan
  'tk', // Tokelau
  'tl', // East Timor (deprecated old code)
  'tm', // Turkmenistan
  'tn', // Tunisia
  'to', // Tonga
  'tp', // East Timor
  'tr', // Turkey
  'tt', // Trinidad and Tobago
  'tv', // Tuvalu
  'tw', // Taiwan, Republic of China
  'tz', // Tanzania
  'ua', // Ukraine
  'ug', // Uganda
  'uk', // United Kingdom
  'um', // United States Minor Outlying Islands
  'us', // United States of America
  'uy', // Uruguay
  'uz', // Uzbekistan
  'va', // Vatican City State
  'vc', // Saint Vincent and the Grenadines
  've', // Venezuela
  'vg', // British Virgin Islands
  'vi', // U.S. Virgin Islands
  'vn', // Vietnam
  'vu', // Vanuatu
  'wf', // Wallis and Futuna
  'ws', // Samoa (formerly Western Samoa)
  'ye', // Yemen
  'yt', // Mayotte
  'yu', // Serbia and Montenegro (originally Yugoslavia)
  'za', // South Africa
  'zm', // Zambia
  'zw' // Zimbabwe
  ]);

LOCAL_TLD_LIST := TList<String>.Create;
LOCAL_TLD_LIST.AddRange(['localhost', // RFC2606 defined
  'localdomain' // Also widely used as localhost.localdomain
  ]);

end.
