<script>
  export let field
  export let value
  export let fresh = true
  export let autocap = 'off'
</script>

<input
  name="value"
  lang="vi"
  type="vi"
  class="input"
  class:fresh
  bind:this={field}
  bind:value
  autocomplete="off"
  autocapitalize={autocap} />

<style lang="scss">
  .input {
    display: block;
    width: 100%;
    margin: 0;
    line-height: 2.5rem;
    padding: 2rem 0.75rem 2.25rem;
    outline: none;

    @include radius;
    @include border;
    @include bgcolor(neutral, 1);
    @include font-size(4);

    &:focus,
    &:active {
      @include bdcolor(primary, 3);
      @include bgcolor(white);
    }
  }

  .fresh {
    font-style: italic;
  }
</style>
