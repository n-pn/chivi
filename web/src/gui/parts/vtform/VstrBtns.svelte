<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { tooltip } from '$lib/actions'
  import type { Vtform } from '$lib/models/viterm'

  // import { type CvtermForm, hint, req_privi } from './_shared'

  export let tform: Vtform
</script>

<div class="opts">
  <button
    type="button"
    class="btn _lg"
    data-kbd="e"
    on:click={() => (tform = tform.clear())}
    use:tooltip={'Xoá nghĩa từ / Xoá phân loại'}
    data-anchor=".vtform">
    <SIcon name="eraser" />
  </button>

  <button
    type="button"
    class="btn _lg"
    data-kbd="r"
    on:click={() => (tform = tform.reset())}
    use:tooltip={'Phục hồi lại nghĩa + phân loại ban đầu'}
    data-anchor=".vtform">
    <SIcon name="corner-up-left" />
  </button>
</div>

<style lang="scss">
  .opts {
    @include flex;

    padding: 0.25rem;
    flex-direction: column;
    margin-left: auto;
  }

  button {
    @include flex-ca;
    height: 1.5rem;
    width: 2rem;

    background: inherit;
    @include ftsize(lg);
    @include fgcolor(tert);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
