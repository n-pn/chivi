<script>
  import MIcon from './MIcon'
</script>

<button
  class={$$props.class}
  m-button={$$props['m-button'] || ''}
  disabled={$$props.disabled}>
  {#if $$props.icon}
    <MIcon m-icon={$$props.icon} />
  {/if}
  {#if $$props.text}
    <span>{$$props.text}</span>
  {/if}
  {#if $$props['icon-right']}
    <MIcon m-icon={$$props['icon-right']} />
  {/if}
</button>
