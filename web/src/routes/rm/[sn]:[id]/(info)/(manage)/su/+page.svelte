<script lang="ts" context="module">
  const guard_locks = [
    [-1, 'Không hạn chế'],
    [0, 'Cần đăng nhập'],
    [1, 'Quyền hạn 1'],
    [2, 'Quyền hạn 2'],
    [3, 'Quyền hạn 3'],
    [4, 'Quyền hạn 4'],
  ]

  const guard_descs = {
    '-1': 'Người chưa đăng nhập cũng có thể thấy thông tin dự án',
    0: 'Người đã đăng nhập cũng có thể thấy thông tin dự án',
    1: 'Quyền hạn tối thiểu là 1 có thể thấy thông tin dự án',
    2: 'Quyền hạn tối thiểu là 2 có thể thấy thông tin dự án',
    3: 'Quyền hạn tối thiểu là 3 có thể thấy thông tin dự án',
    4: 'Ẩn thông tin dự án, chỉ có những người có liên kết mới xem được',
  }

  const gifts_types = [
    [0, 'Không mở miễn phí'],
    [1, '1/4 chương đầu'],
    [2, '1/2 chương đầu'],
    [3, '3/4 chương đầu'],
    [4, 'Tất cả các chương'],
  ]
</script>

<script lang="ts">
  import { goto } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { api_call } from '$lib/api_call'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ rstem, sroot } = data)

  $: can_conf = $_user.privi > 3

  let form = {
    gifts: data.rstem.gifts,
    multp: data.rstem.multp,
  }

  let errs = ''

  const action = `/_rm/rmstems/${rstem.sname}/${rstem.sn_id}`

  const update_conf = async () => {
    try {
      rstem = await api_call(action, form, 'PATCH')
      goto(sroot)
    } catch (ex) {
      errs = ex.body.message
    }
  }

  $: gifts_chap = calc_gifts_chap(form.gifts)

  const calc_gifts_chap = (gifts_type: number) => {
    if (gifts_type == 0) return 0
    const gifts_chap = Math.round((data.rstem.chap_count * gifts_type) / 4)
    return gifts_chap < 40 ? 40 : gifts_chap
  }
</script>

<details open>
  <summary>Thiết đặt phạm vi chương miễn phí không cần thiết mở khóa</summary>
  <p class="hints">
    Lưu ý: 40 chương đầu luôn luôn miễn phí, trừ khi bạn dùng chế độ không miễn
    phí!
  </p>

  <div class="options">
    {#each gifts_types as [value, label]}
      <label class="radio">
        <input type="radio" {value} bind:group={form.gifts} />
        <span>{label}</span>
      </label>
    {/each}
  </div>
  <p class="hints">
    {#if gifts_chap > 0}
      Các chương từ 1 tới {gifts_chap} sẽ được miễn phí. Các chương từ {gifts_chap +
        1}
      tới {rstem.chap_count} sẽ cần thiết phải mở khóa.
    {:else}
      Tất cả các chương từ 1 tới {rstem.chap_count} sẽ cần phải thanh toán vcoin
      để mở khóa.
    {/if}
  </p>
</details>

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
        <input type="radio" {value} bind:group={form.multp} />
        <span>{value}x</span>
      </label>
    {/each}
    <label>
      <span>Tự chọn:</span>
      <input type="number" class="m-input _sm _multp" bind:value={form.multp} />
    </label>
  </div>
  <p class="hints">
    Công thức tính: <code>1 vcoin / 100_000 chữ * hệ số nhân.</code>
  </p>
</details>

{#if errs}<div class="form-msg _err">{errs}</div>{/if}

<footer class="action">
  <button
    class="m-btn _primary _fill"
    disabled={!can_conf}
    on:click={update_conf}>
    <SIcon name="device-floppy" />
    <span>Lưu thay đổi</span>
  </button>
</footer>

<!-- <details>
    <summary>Sao chép từ danh sách chương tiết khác</summary>
    <CopyChapters
      book_info={nvinfo}
      seed_list={data.seed_list}
      {curr_seed}
      {can_edit}
      {edit_url} />
  </details> -->

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
