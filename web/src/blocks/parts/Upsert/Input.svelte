<script>
  import AIcon from '$atoms/AIcon'

  export let input = ''
  export let lower = 0
  export let upper = 0
  export let output = ''

  $: prefix = input.substring(lower - 2, lower)
  $: output = input.substring(lower, upper)
  $: suffix = input.substring(upper, upper + 2)
</script>

<div>
  <button disabled={lower == 0} on:click={() => (lower -= 1)}>
    <AIcon name="chevron-left" />
  </button>

  <button
    class="_bd"
    disabled={lower == upper - 1}
    on:click={() => (lower += 1)}>
    <AIcon name="chevron-right" />
  </button>

  <span class="output">
    <span class="sub">{prefix}</span>
    <span class="key">{output}</span>
    <span class="sub">{suffix}</span>
  </span>

  <button
    class="_bd"
    disabled={upper == lower + 1}
    on:click={() => (upper -= 1)}>
    <AIcon name="chevron-left" />
  </button>

  <button disabled={upper == input.length} on:click={() => (upper += 1)}>
    <AIcon name="chevron-right" />
  </button>
</div>

<style lang="scss">
  $height: 2.25rem;

  div {
    display: flex;
    width: 100%;
    height: $height;
    overflow: hidden;
    line-height: $height;

    @include radius();
    @include bgcolor(neutral, 1);
    @include border($color: neutral, $shade: 3);
  }

  .output {
    flex-grow: 1;
    display: inline-flex;
    justify-content: center;
    overflow: hidden;
  }

  .key {
    font-weight: 500;
    @include fgcolor(neutral, 7);
    @include truncate(null);
    max-width: 8em;
  }

  .sub {
    @include fgcolor(neutral, 4);
  }

  button {
    background: transparent;
    padding: 0 0.375rem;
    margin: 0;
    line-height: 1em;
    @include font-size(4);
    @include fgcolor(neutral, 7);

    @include hover {
      background-color: #fff;
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }

    &._bd {
      @include border($sides: left-right);
    }
  }
</style>
