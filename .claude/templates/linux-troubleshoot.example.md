# Example: Linux troubleshooting (2026-09-29)

Real output from session 432cf3ec, prompt: "my display resolution is not right". Pasted unedited (two consecutive replies).

---

amdgpu isn't loaded — you're on the `simpledrm` fallback framebuffer, which is why you're stuck at 1024x768. Checking why:

-----

Found it. Your GPU (AMD Lucienne, integrated) has no driver loaded because `/etc/modprobe.d/blacklist.conf` has `blacklist amdgpu` in it. So the kernel falls back to `simpledrm`, a dumb framebuffer with no EDID. That's why Hyprland sees a nameless `Unknown-1` monitor with only one 1024x768 mode.

No package owns that file, and it was last changed **today at 14:54, one minute before your current boot**. Did you or some script/tutorial create it? If you don't recognize it, work out where it came from, because whatever wrote it could do it again.

**Fix** (fish). Remove only the amdgpu line and leave the other blacklists in place:

```fish
sudo sed -i '/^blacklist amdgpu$/d' /etc/modprobe.d/blacklist.conf
sudo mkinitcpio -P
reboot
```

`mkinitcpio -P` is there because the `modconf` hook copies modprobe.d into the initramfs, so the blacklist may be baked in there too.

If you'd rather test without rebooting, `sudo modprobe amdgpu` might take over the display live. It can also leave you on a black screen until you reboot, so the reboot is the cleaner option.

After the reboot, `hyprctl monitors` should show a real name like `eDP-1` with your panel's native resolution. If it doesn't, send me the output.
