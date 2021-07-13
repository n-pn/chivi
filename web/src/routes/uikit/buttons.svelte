<script>
  import MButton from '$atoms/MButton.svelte'

  const sizes = ['xs', 'sm', 'md', 'lg', 'xl']
  const styles = ['fill', 'text']
  const variants = ['default', 'primary', 'success', 'warning', 'harmful']
</script>

<svelte:head>
  <title>Buttons - Molds</title>
</svelte:head>

<article class="m-article">
  <h1>Buttons</h1>

  <h2>Variants</h2>

  {#each styles as style}
    <div class="button-list">
      {#each variants as variant}
        <MButton class="m-button _{style} _{variant}" text={variant} />
      {/each}
    </div>

    <div class="button-list">
      {#each variants as variant}
        <MButton class="m-button _{style} _{variant}" disabled text={variant} />
      {/each}
    </div>
    <hr />
  {/each}

  <h2>Elements</h2>

  <div class="button-list">
    {#each styles as style}
      <a href="/" class="m-button _primary _{style}"> <span>Link</span> </a>
    {/each}

    {#each styles as style}
      <label class="m-button _harmful _{style}">
        <span>Input</span>
        <input type="button" />
      </label>
    {/each}
  </div>

  <h2>Sizes</h2>

  <div class="button-list">
    {#each sizes as size}
      <MButton
        class="m-button btn-{size}"
        text="{size} button"
        icon="maximize" />
    {/each}
  </div>

  <h2>Icons</h2>

  <div class="button-list">
    <MButton class="m-button" icon="feather" />
    <MButton class="m-button _success" icon="circle" />
    <MButton class="m-button _line _harmful" icon="x" text="Close" />
    <MButton class="m-button _primary" icon-right="arrow-right" text="Next" />
    <MButton
      disabled
      class="m-button"
      icon="chevron-left"
      icon-right="chevron-right"
      text="Left and right" />
  </div>

  <h2>Mixed up with utilties</h2>
  <h3>Border radius:</h3>

  <div class="button-list">
    {#each variants as variant}
      <MButton class="m-button _{variant} u-rd-x" text={variant} />
    {/each}
  </div>

  <h3>With shadows:</h3>
  <div class="button-list">
    {#each variants as variant}
      <MButton class="m-button _{variant} u-sd-2" text={variant} />
    {/each}
  </div>
</article>

<style lang="scss">
  .button-list {
    @include flex($wrap: nowrap, $gap: 0.5rem);
  }

  .m-button > input {
    display: none !important;
  }
</style>
