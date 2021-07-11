<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let term
  export let p_max
  export let p_min

  function btn_style(term) {
    if (term.privi < term.old_privi) return '_text'
    return term.privi == term.old_privi ? '_line' : '_solid'
  }

  function btn_color(term) {
    switch (term.state) {
      case 'Thêm':
        return '_success'
      case 'Sửa':
        return '_primary'
      default:
        return '_harmful'
    }
  }
</script>

<div class="privi">
  <div class="txt"><span class="lbl">Q.h:</span>{term.privi}</div>
  <button
    class="btn -up"
    disabled={term.privi >= p_max}
    on:click={() => (term.privi += 1)}><SIcon name="chevron-up" /></button>
  <button
    class="btn -dn"
    disabled={term.privi < 2}
    on:click={() => (term.privi -= 1)}><SIcon name="chevron-down" /></button>
</div>

<button
  class="submit m-button _large {btn_style(term)} {btn_color(term)}"
  disabled={p_max <= p_min}
  on:click>
  <span class="-text">{term.state}</span>
</button>

<style lang="scss">
  .privi {
    margin-left: 0.75rem;
    padding-left: 0.5rem;
    padding-right: 1.75rem;

    position: relative;
    font-weight: 500;

    @include border;
    @include radius;
  }

  .txt {
    display: inline-block;
    line-height: 2.625rem;
    @include fgcolor(neutral, 8);
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

  .submit {
    margin-left: 0.75rem;
    justify-content: center;
    width: 4rem;
  }
</style>
