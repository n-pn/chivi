<script>
  import MButton from '$atoms/MButton.svelte'

  const sizes = ['xs', 'sm', 'md', 'lg', 'xl']
  const styles = ['fill', 'text']
  const variants = ['default', 'primary', 'success', 'warning', 'harmful']
</script>

<svelte:head>
  <title>Buttons - Molds</title>
</svelte:head>

<h1>Buttons</h1>

<h2>Variants</h2>

{#each styles as style}
  <div class="button-list">
    {#each variants as variant}
      <MButton class="m-btn _{style} _{variant}" text={variant} />
    {/each}
  </div>

  <div class="button-list">
    {#each variants as variant}
      <MButton class="m-btn _{style} _{variant}" disabled text={variant} />
    {/each}
  </div>
  <hr />
{/each}

<h2>Elements</h2>

<div class="button-list">
  {#each styles as style}
    <a href="/" class="m-btn _primary _{style}"> <span>Link</span> </a>
  {/each}

  {#each styles as style}
    <label class="m-btn _harmful _{style}">
      <span>Input</span>
      <input type="button" />
    </label>
  {/each}
</div>

<h2>Sizes</h2>

<div class="button-list">
  {#each sizes as size}
    <MButton class="m-btn btn-{size}" text="{size} button" icon="maximize" />
  {/each}
</div>

<h2>Icons</h2>

<div class="button-list">
  <MButton class="m-btn" icon="feather" />
  <MButton class="m-btn _success" icon="circle" />
  <MButton class="m-btn _line _harmful" icon="x" text="Close" />
  <MButton class="m-btn _primary" icon-right="arrow-right" text="Next" />
  <MButton
    disabled
    class="m-btn"
    icon="chevron-left"
    icon-right="chevron-right"
    text="Left and right" />
</div>

<h2>Mixed up with utilties</h2>
<h3>Border radius:</h3>

<div class="button-list">
  {#each variants as variant}
    <MButton class="m-btn _{variant} u-rd-x" text={variant} />
  {/each}
</div>

<h3>With shadows:</h3>
<div class="button-list">
  {#each variants as variant}
    <MButton class="m-btn _{variant} u-sd-2" text={variant} />
  {/each}
</div>

<style lang="scss">
  .button-list {
    @include flex($wrap: nowrap, $gap: 0.5rem);
    margin-top: 1rem;
  }

  .m-btn > input {
    display: none !important;
  }
</style>
