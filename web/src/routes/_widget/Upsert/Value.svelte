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
    @include border();
    @include bgcolor(neutral, 1);

    &:focus,
    &:active {
      @include bgcolor(white);
      @include bdcolor($color: primary, $shade: 3);
    }
  }

  .fresh {
    font-style: italic;
  }
</style>
