<script>
  export let field
  export let value
  export let fresh = true
  export let autocap = 'off'
</script>

<input
  lang="vi"
  type="text"
  name="value"
  class:fresh
  bind:this={field}
  bind:value
  autocomplete="off"
  autocapitalize={autocap} />

<style lang="scss">
  input {
    display: block;
    width: 100%;
    margin: 0;
    line-height: 1.5rem;
    padding: 0.75rem;

    outline: none;
    border: none;
    background-color: inherit;
    box-shadow: 0 0 0 1px color(neutral, 3);
    z-index: 2;

    &:focus,
    &:active {
      box-shadow: 0 0 0 1px color(primary, 3);
      @include bgcolor(white);
    }
  }

  .fresh {
    font-style: italic;
  }
</style>
