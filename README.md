# Nvidia Fan Curve

Keep those Nvidia GPU's cool and efficient by setting a desired temperature and have fan-control.pl automatically adjust each GPU's fan speed to maintain your temperature.

![ScreenShot](https://github.com/imcmurray/nvidia-fan-curve/blob/master/screenshot.png)

## Use

Simply download this respository, or just the fan-control.pl file to your miner, make it executable (chmod +x fan-control.pl), then simply execute it (./fan-control.pl).

The default settings are 68C temperature for each GPU with a refresh of 15 seconds, but you can change that by modifying the following section in fan-control.pl:

```perl
# Set your desired GPU temperature in Celsius below:
my $targettemp=68;
# Set the duration between captures in Seconds below:
my $timetosleep=15;
```

I also assume that you have already already installed the Nvidia drivers and have set them up accordingly. If you're simply ramping up your fans to 100% then this could save you a few watts of power buy adjusting and maintaining a desired temperature. Lower wattage means more profit.

Your feedback is greatly appreciate.

---

Find this useful? Then why not send me some Zcash if you did:

> t1YQLYazSJMDTdJXkoJqaiashkhQspRi15u

(visible to the Zcash blockchain)

or if you want to be totally anonymous, use my z_address:

> zcWF35W9fvNczXC9cWoJQ1M7pCJRamvWV6VFzDrM55b3zrqrjSFPv7zv1ybXzDEBPWF5hepst9t4m3f4uSFVzfb4BsmdGUN

(Hidden in the blockchain - awesome Zcash)

