$modelname "propPlayer.mdl"
$body modelbody "propPlayer.smd"
$surfaceprop propplayer
$cdmaterials "models\props"
$staticprop
 
$sequence idle "propPlayer.smd"
 
$collisionmodel	"propPlayer.smd"
{
  $mass "1000"
  $masscenter 0.0 0.0 -32.0
  $concave
}

$keyvalues
{
  prop_data
  {
    "allowstatic" "1"
    "base" "Metal.Medium"
  }
}