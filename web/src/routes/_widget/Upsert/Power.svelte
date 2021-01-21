<script>
  import SvgIcon from '$atoms/SvgIcon'

  export let power
  export let p_max
</script>

<div class="power">
  <div class="txt"><span class="lbl">Q.h:</span>{power}</div>
  <button
    class="btn -up"
    disabled={power == p_max}
    on:click={() => (power += 1)}><SvgIcon name="chevron-up" /></button>
  <button class="btn -dn" disabled={power == 0} on:click={() => (power -= 1)}
    ><SvgIcon name="chevron-down" /></button>
</div>

<style lang="scss">
  .power {
    padding-left: 0.5rem;
    padding-right: 1.625rem;

    position: relative;
    font-weight: 500;

    @include border;
    @include radius;
  }

  .txt {
    display: inline-block;
    line-height: 2.625rem;
  }

  .lbl {
    padding-right: 0.2em;
    @include fgcolor(neutral, 5);
  }

  .btn {
    position: absolute;
    right: 0;
    background-color: transparent;
  }

  .-up {
    top: 0;
  }

  .-dn {
    bottom: 0;
  }
</style>
