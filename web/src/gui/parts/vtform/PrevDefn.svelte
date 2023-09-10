<script lang="ts">
  import { rel_time_vp } from '$utils/time_utils'
  import type { CvtermForm } from './_shared'

  export let form: CvtermForm
  export let dicts: CV.Cvdict[]

  const save_modes = ['Tự động', 'Chung', 'Riêng', 'Riêng']

  $: vdict = form.init.dic >= 0 ? dicts[0] : dicts[1]
  $: dname = vdict.vd_id > 0 ? vdict.label : `Tất cả bộ truyện`
</script>

<div class="emend">
  {#if form.init.mtime > 0}
    <span>{form.init.state}:</span>
    <span class="bold">{rel_time_vp(form.init.mtime)}</span>
    <span>bởi</span>
    <span class="bold trim">{form.init.uname || '_'}</span>
    <span>Cho:</span>
    <span class="bold trim _dic">{dname}</span>
    <em>({save_modes[Math.abs(form.init.tab)]})</em>
  {:else}
    <em>Chưa có lịch sử sửa từ</em>
  {/if}
</div>

<style lang="scss">
  .emend {
    @include flex($center: horz, $gap: 0.2rem);
    @include clamp();

    padding: 0.25rem 0;
    line-height: 1.5rem;
    @include ftsize(xs);
    @include fgcolor(tert);
  }

  .bold {
    font-weight: 500;
  }

  .trim {
    @include clamp($width: null);

    &._dic {
      text-overflow: elipsis;
      max-width: 8.5rem;
    }
  }
</style>
