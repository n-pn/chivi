<script lang="ts">
  import { goto } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { api_call } from '$lib/api_call'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ crepo, sroot } = data)

  let cform = {
    pdict: data.crepo.pdict || '',
    multp: data.crepo.multp,
  }

  let errs = ''

  $: action = `/_rd/tsrepos/${crepo.sname}/${crepo.sn_id}`

  const update_conf = async () => {
    try {
      crepo = await api_call(action, cform, 'PATCH')
      goto(sroot)
    } catch (ex) {
      errs = ex.body.message
    }
  }
</script>

<details open>
  <summary
    >Hệ số nhân theo số lượng chữ để tính vcoin cần thiết khi mở chương</summary>
  <p class="hints">
    Tùy vào độ hiếm có, đặc dị, mức độ hoàn thiện của nội dung mà bạn có thể
    thiết đặt giá chương sao cho hợp lý
  </p>

  <div class="options">
    {#each [1, 2, 3, 4, 5, 10, 20] as value}
      <label class="radio">
        <input type="radio" {value} bind:group={cform.multp} />
        <span>{value}x</span>
      </label>
    {/each}
    <label>
      <span>Tự chọn:</span>
      <input
        type="number"
        class="m-input _sm _multp"
        bind:value={cform.multp} />
    </label>
  </div>
  <p class="hints">
    Công thức tính: <code>1 vcoin / 100_000 chữ * hệ số nhân.</code>
  </p>
</details>

<details open>
  <summary>Chọn từ điển chính khi sử dụng chế độ dịch máy</summary>
  <p class="hints">
    Bạn có thể dùng từ điển riêng độc lập, hoặc dùng chung với từ điển bộ truyện
    được liên kết.
  </p>

  <div class="options">
    <label class="radio">
      <input
        type="radio"
        value={crepo.stype == 1 ? `up${crepo.sn_id}` : 'combine'}
        bind:group={cform.pdict} />
      <span>Dùng từ điển độc lập</span>
    </label>

    <label class="radio">
      <input
        type="radio"
        value="wn{crepo.wn_id}"
        bind:group={cform.pdict}
        disabled={crepo.wn_id < 1} />
      <span>Dùng từ điển bộ truyện</span>
    </label>
  </div>
</details>

{#if errs}<div class="form-msg _err">{errs}</div>{/if}

<footer class="action">
  <button
    class="m-btn _primary _fill"
    disabled={$_user.privi < 1}
    on:click={update_conf}>
    <SIcon name="device-floppy" />
    <span>Lưu thay đổi</span>
  </button>
</footer>

<style lang="scss">
  details {
    @include border(--bd-soft, $loc: bottom);
    padding: 0.5rem 0;
  }

  summary {
    font-weight: 500;
    line-height: 2rem;
    @include ftsize(lg);
    @include fgcolor(secd);

    &:hover,
    details[open] & {
      @include fgcolor(primary, 5);
    }
  }

  .hints {
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(tert);
    line-height: 1rem;
    margin-top: 0.5rem;
  }

  .options {
    display: flex;
    flex-wrap: wrap;
    margin-top: 0.75rem;
  }

  .radio {
    cursor: pointer;
    display: inline-flex;
    line-height: 1.5rem;
    padding: 0.25rem 0;
    margin-right: 0.5rem;
    input {
      margin-right: 0.25rem;
    }
  }

  .action {
    @include flex($gap: 0.75rem);
    padding: 0.75rem 0;
    justify-content: right;
  }

  ._multp {
    width: 3rem;
    padding-left: 0.25rem;
    padding-right: 0.25rem;
    text-align: center;
  }
</style>
