<script>
  export let name = 'feather'
  export let spin = false
</script>

<svg class="m-icon" class:a-spin={spin} viewBox="0 0 24 24">
  {#if name == 'erase'}
    <path stroke="none" d="M0 0h24v24H0z" fill="none" />
    <path
      d="M19 19h-11l-4 -4a1 1 0 0 1 0 -1.41l10 -10a1 1 0 0 1 1.41 0l5 5a1 1 0 0 1 0 1.41l-9 9" />
    <line x1="18" y1="12.3" x2="11.7" y2="6" />
  {:else if name == 'pin'}
    <path stroke="none" d="M0 0h24v24H0z" fill="none" />
    <path d="M15 4.5l-4 4l-4 1.5l-1.5 1.5l7 7l1.5 -1.5l1.5 -4l4 -4" />
    <line x1="9" y1="15" x2="4.5" y2="19.5" />
    <line x1="14.5" y1="4" x2="20" y2="9.5" />
  {:else}
    <use xlink:href="/icons.svg#{name}" />
  {/if}
</svg>
