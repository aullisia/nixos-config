{ den, ... }:
{
  den.aspects.swap.nixos = {
    # --- ZRAM ---
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100; # allow up to 100% of RAM as compressed swap
      swapDevices = 1;
      priority = 100; # prefer zram over swapfile
    };

    # --- SWAPFILE ---
    swapDevices = [{
      device = "/persistent/var/lib/swapfile";
      size = 16 * 1024;
      priority = 10; # lower priority than zram
    }];

    # --- KERNEL MEMORY TUNING ---
    boot.kernel.sysctl = {
      # Very low swappiness: kernel avoids swapping unless truly necessary.
      # 10 = strongly prefer dropping caches over swapping processes out.
      "vm.swappiness" = 10;

      # How aggressively the kernel reclaims memory used for VFS cache.
      # 50 = balanced. Lower = keep more cache, higher = reclaim more.
      "vm.vfs_cache_pressure" = 50;

      # Start writing dirty pages to disk when 10% of RAM is dirty.
      # Prevents sudden large I/O spikes during gaming.
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;

      # Overcommit: allow programs to allocate more memory than physically
      # available. Games and Wine/Proton rely on this heavily.
      # 1 = always overcommit (never refuse allocation).
      "vm.overcommit_memory" = 1;
    };

    # --- OOM KILLER ---
    systemd.oomd = {
      enable = true;
      enableRootSlice = true;
      enableSystemSlice = true;
      enableUserSlices = true;
    };
  };
}