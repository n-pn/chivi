<script lang="ts">
  import { get_user } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData
  const _user = get_user()

  let dl_opts = {
    format: 'qt',
    scope: 'all',
    temp: true,
    user: true,
    to_query() {
      const fields = ['format', 'scope', 'temp', 'user']
      return fields.map((x) => `${x}=${this[x]}`).join('&')
    },
  }
</script>

<details class="export">
  <summary>Tải từ điển về máy </summary>
  <div class="dl-opt">
    <span class="dl-lbl">Giới hạn số lượng từ:</span>
    <label
      ><input
        type="radio"
        name="dl-scope"
        bind:group={dl_opts.scope}
        value="all" /> Tất cả các từ trong từ điển</label>
    <label
      ><input
        type="radio"
        name="dl-scope"
        bind:group={dl_opts.scope}
        value="top" /> Mười nghìn từ gần nhất</label>
  </div>

  <div class="dl-opt">
    <span class="dl-lbl">Bao gồm các từ trong:</span>
    <label data-tip="Từ điển áp dụng chung cho tất cả mọi người"
      ><input type="checkbox" checked name="dl-main" disabled value="main" /> Từ
      điển chung</label>

    <label data-tip="Từ lưu ở chế độ lưu tạm thời"
      ><input type="checkbox" name="dl-temp" bind:checked={dl_opts.temp} /> Từ điển
      nháp</label>
    <label data-tip="Từ lưu trong từ điển cá nhân của bạn"
      ><input type="checkbox" name="dl-user" bind:checked={dl_opts.user} /> Từ điển
      riêng</label>
  </div>

  <div class="dl-opt">
    <span class="dl-lbl">Định dạng:</span>
    <label
      ><input
        type="radio"
        name="dl-format"
        bind:group={dl_opts.format}
        value="qt" /> Kiểu QuickTranslator (chỉ có từ và nghĩa)</label>
    <label
      ><input
        type="radio"
        name="dl-format"
        bind:group={dl_opts.format}
        value="cv" /> Kiểu Chivi (có kèm từ loại và luật ưu tiên)</label>
  </div>

  <div class="action">
    <a
      href="/_m1/dicts/{data.dname}/export?{dl_opts.to_query()}"
      download="{data.label}.{dl_opts.format == 'q' ? 'txt' : 'tsv'}"
      class="m-btn _primary _fill _lg"
      class:_disable={$_user.privi < 1}>
      <SIcon name="download" />
      <span>Tải xuống</span>
    </a>
  </div>
</details>

<style lang="scss">
  .export {
    margin-bottom: 1.5rem;

    summary {
      @include ftsize(lg);
      line-height: 2rem;
      font-weight: 500;
      margin-bottom: 0.5rem;

      &:hover {
        @include fgcolor(primary, 5);
      }
    }

    label {
      cursor: pointer;
    }

    .action {
      margin-top: 0.25rem;
      // @include flex-cx;
    }

    a {
      // display: inline-block;
      width: 10rem;
    }
  }

  .dl-opt {
    display: flex;
    gap: 0.75rem;
    line-height: 2rem;
    margin: 0.5rem 0;
    // margin-bottom: 0.5rem;
  }

  .dl-lbl {
    @include fgcolor(secd);
    font-weight: 500;
  }
</style>
