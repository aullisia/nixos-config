{ den, ... }:
let
  aul = {
    gitName = "aullisia";
    gitEmail = "aullisia.dev@gmail.com";
  };
  timezone = "Europe/Brussels";
in
{
  den.hosts.x86_64-linux = {
    test = {
      users.aul = aul;
      ## Freeform attributes
      timezone = timezone;
    };
    b660 = {
      users.aul = aul;
      ## Freeform attributes
      timezone = timezone;
    };
  };
}