<script>
  import SIcon from '$gui/atoms/SIcon.svelte'
</script>

<button class={$$props.class} disabled={$$props.disabled} on:click>
  {#if $$props.icon}
    <SIcon name={$$props.icon} />
  {/if}
  {#if $$props.text}
    <span>{$$props.text}</span>
  {/if}
  {#if $$props['icon-right']}
    <SIcon name={$$props['icon-right']} />
  {/if}
</button>
