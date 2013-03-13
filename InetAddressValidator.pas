unit InetAddressValidator;

interface

uses RegularExpressions;

const
  IPV4_REGEX = '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$';

type

  TInetAddressValidator = class
  private
    ipv4Validator: TRegEx;
  public
    constructor Create; overload;
    function isValid(const inetAddress: String): Boolean;
    function isValidInet4Address(const inet4Address: String): Boolean;
  end;

implementation

uses SysUtils;

constructor TInetAddressValidator.Create;
begin
  inherited;
  ipv4Validator := TRegEx.Create(IPV4_REGEX);
end;

function TInetAddressValidator.isValid(const inetAddress: String): Boolean;
begin
  Result := isValidInet4Address(inetAddress);
end;

function TInetAddressValidator.isValidInet4Address(const inet4Address
  : String): Boolean;
var
  Match: TMatch;
  IpSegment: Integer;
  i: Integer;
begin
  Match := ipv4Validator.Match(inet4Address);

  // if Match.Groups.Count <> 4 then
  // Exit(false);

  IpSegment := 0;
  for i := 1 to Match.Groups.Count - 1 do
  begin
    try
      IpSegment := StrToInt(Match.Groups[i].Value);
    except
      Exit(false);
    end;

    if IpSegment > 255 then
      Exit(false);
  end;
  Result := true;
end;

end.
