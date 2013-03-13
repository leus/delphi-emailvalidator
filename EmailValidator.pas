(*
   Copyright 2013 - Leonardo Herrera (leonardo.herrera@gmail.com)

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
unit EmailValidator;

interface

uses RegularExpressions, InetAddressValidator;

type
  TEmailValidator = class
  private
    MATCH_ASCII_PATTERN, EMAIL_PATTERN, IP_DOMAIN_PATTERN, USER_PATTERN: TRegEx;
    allowLocal: Boolean;
    InetAddressValidator: TInetAddressValidator;
  public
    constructor Create; overload;
    destructor Destroy; override;
    function isValid(const EmailAddress: String): Boolean;
    function isValidDomain(const Domain: String): Boolean;
    function isValidUser(const User: String): Boolean;
  end;

implementation

uses DomainValidator, SysUtils;

const
  SPECIAL_CHARS = '\p{Cc}\(\)<>@,;:''\\"\.\[\]';
  VALID_CHARS = '[^\s' + SPECIAL_CHARS + ']';
  QUOTED_USER = '("[^"]*")';
  WORD = '((' + VALID_CHARS + '|'')+|' + QUOTED_USER + ')';
  LEGAL_ASCII_REGEX = '^.+$';
  EMAIL_REGEX = '^\s*?(.+)@(.+?)\s*$';
  IP_DOMAIN_REGEX = '^\[(.*)\]$';
  USER_REGEX = '^\s*' + WORD + '(\.' + WORD + ')*$';

constructor TEmailValidator.Create;
begin
  inherited;
  MATCH_ASCII_PATTERN := TRegEx.Create(LEGAL_ASCII_REGEX);
  EMAIL_PATTERN := TRegEx.Create(EMAIL_REGEX);
  IP_DOMAIN_PATTERN := TRegEx.Create(IP_DOMAIN_REGEX);
  USER_PATTERN := TRegEx.Create(USER_REGEX);
  Self.InetAddressValidator := TInetAddressValidator.Create;
end;

destructor TEmailValidator.Destroy;
begin
  FreeAndNil(Self.InetAddressValidator);
  inherited;
end;

function TEmailValidator.isValid(const EmailAddress: String): Boolean;
var
  match: TMatch;
begin
  if not MATCH_ASCII_PATTERN.match(EmailAddress).Success then
    exit(False);

  match := EMAIL_PATTERN.match(EmailAddress);
  if not match.Success then
    exit(False);

  if EmailAddress[Length(EmailAddress)] = '.' then
    exit(False);

  if match.Groups.Count < 2 then
    exit(False);

  if not isValidUser(match.Groups.Item[1].Value) then
    exit(False);

  if not isValidDomain(match.Groups.Item[2].Value) then
    exit(False);

  Result := true;
end;

function TEmailValidator.isValidDomain(const Domain: String): Boolean;
var
  match: TMatch;
  DomainValidator: TDomainValidator;
begin
  // see if domain is an IP address in brackets
  match := IP_DOMAIN_PATTERN.match(Domain);
  if match.Success then
  begin
    Result := InetAddressValidator.isValid(match.Groups[1].Value);
  end
  else
  begin
    // Domain is symbolic name
    DomainValidator := TDomainValidator.Create;
    Result := DomainValidator.isValid(Domain);
    DomainValidator.Free;
  end;
end;

function TEmailValidator.isValidUser(const User: String): Boolean;
begin
  Result := USER_PATTERN.match(User).Success;
end;

end.
